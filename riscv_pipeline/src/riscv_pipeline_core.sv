`timescale 1ns/1ps

import defines::*;

module riscv_pipeline_core (
  input logic clk,
  input logic rst_n
);

  // ================================================= //
  //              Fetch Stage Signals                  //
  // ================================================= //
  
  
  logic [DATA_WIDTH-1:0] pc_IF;
  logic [DATA_WIDTH-1:0] pc_plus4_IF;
  logic [DATA_WIDTH-1:0] pc_sel_IF;
  logic [DATA_WIDTH-1:0] instruction_IF;

  
  // ================================================= //
  //             Decode Stage Signals                  //
  // ================================================= //
  logic [6:0] opcode_ID;
  logic [4:0] rs1_addr_ID, rs2_addr_ID;
  logic [4:0] rd_addr_ID;
  logic ALUSrc1_ID, ALUSrc2_ID, RegWrite_ID, Branch_ID, Jump_ID, MemWrite_ID, MemRead_ID;
  imm_sel_e ImmSel_ID;
  alu_op_e ALUOp_ID;
  wb_sel_e WBSel_ID;

  logic [DATA_WIDTH-1:0] imm_i_ID, imm_s_ID, imm_b_ID, imm_u_ID, imm_j_ID;
  logic [DATA_WIDTH-1:0] ImmVal_ID;
  logic [DATA_WIDTH-1:0] rd_data1_ID, rd_data2_ID;
  logic [DATA_WIDTH-1:0] pc_ID, pc_plus4_ID;
  logic [DATA_WIDTH-1:0] instruction_ID;
  logic [DATA_WIDTH-1:0] branch_target_adder_ID;

  assign branch_target_adder_ID = pc_ID + ImmVal_ID;
  assign opcode_ID = instruction_ID[6:0];
  assign rd_addr_ID = instruction_ID[11:7];
  assign rs1_addr_ID = instruction_ID[19:15];
  assign rs2_addr_ID = instruction_ID[24:20];
  // ================================================= //
  //             Execute Stage Signals                 //
  // ================================================= //
  wb_sel_e WBSel_EX;
  alu_op_e ALUOp_EX;
  alu_sel_e ALUSel_EX;
  logic ALUSrc1_EX, ALUSrc2_EX, RegWrite_EX, Branch_EX, Jump_EX, MemWrite_EX, MemRead_EX;
  logic [6:0] funct7_EX;
  logic [2:0] funct3_EX;
  
  logic [DATA_WIDTH-1:0] instruction_EX;
  logic [DATA_WIDTH-1:0] pc_EX, pc_plus4_EX;
  logic [DATA_WIDTH-1:0] rd_data1_EX, rd_data2_EX;
  logic [DATA_WIDTH-1:0] ImmVal_EX;
  logic [DATA_WIDTH-1:0] operand1_EX, operand2_EX;
  logic [DATA_WIDTH-1:0] alu_result_EX;
  logic [DATA_WIDTH-1:0] branch_target_adder_EX;

  assign funct3_EX = instruction_EX[14:12];
  assign funct7_EX = instruction_EX[30]; // only for ALUControl

	assign operand1_EX = (ALUSrc1_EX) ? pc_EX  : rd_data1_EX;
	assign operand2_EX = (ALUSrc2_EX) ? ImmVal_EX : rd_data2_EX;


  // ================================================= //
  //              Memory Stage Signals                 //
  // ================================================= //
  wb_sel_e WBSel_MEM;
  logic RegWrite_MEM, Branch_MEM, Jump_MEM, MemWrite_MEM, MemRead_MEM, PCSrc_MEM;
  logic [DATA_WIDTH-1:0] alu_result_MEM;
  logic [DATA_WIDTH-1:0] instruction_MEM;
  logic [DATA_WIDTH-1:0] rd_data2_MEM;
  logic [DATA_WIDTH-1:0] pc_plus4_MEM;
  logic [DATA_WIDTH-1:0] rd_data_MEM;
  logic [DATA_WIDTH-1:0] branch_target_adder_MEM;
  logic zero_flag_MEM;

  logic [2:0] funct3_MEM;
  assign funct3_MEM = instruction_MEM[14:12];

  logic sign_flag_MEM;
  assign sign_flag_MEM = alu_result_MEM[DATA_WIDTH-1];

  always_comb begin
    PCSrc_MEM = 1'b0; // 기본값은 분기 안 함
    if (Branch_MEM) begin // 분기 명령어일 경우에만 조건을 검사
      case (funct3_MEM)
          // beq (funct3 = 000): Z=1이면 분기
          FUNCT3_BEQ: PCSrc_MEM = zero_flag_MEM;
          // bne (funct3 = 001): Z=0이면 분기
          FUNCT3_BNE: PCSrc_MEM = ~zero_flag_MEM;
          // blt (funct3 = 100): N=1이면 분기 (a-b < 0)
          FUNCT3_BLT: PCSrc_MEM = sign_flag_MEM;
          // bge (funct3 = 101): N=0이면 분기 (a-b >= 0)
          FUNCT3_BGE: PCSrc_MEM = ~sign_flag_MEM;
          // bltu (funct3 = 110): ALU 결과의 최상위 비트(carry out)가 필요.
          // bgeu (funct3 = 111): ALU 결과의 최상위 비트(carry out)가 필요.
          // (참고: 부호 없는 비교를 위해서는 ALU에서 carry_out 신호가 추가로 필요합니다)
          default: PCSrc_MEM = 1'b0;
      endcase
    end
  end

  assign pc_plus4_IF = pc_IF + 32'd4;
  assign pc_sel_IF = (Jump_MEM || PCSrc_MEM) ? branch_target_adder_MEM : pc_plus4_IF;

  // ================================================= //
  //           Write Back Stage Signals                //
  // ================================================= //
  wb_sel_e WBSel_WB;
  logic RegWrite_WB;
  logic [DATA_WIDTH-1:0] pc_plus4_WB;
  logic [DATA_WIDTH-1:0] alu_result_WB;
  logic [DATA_WIDTH-1:0] rd_data_WB;
  logic [DATA_WIDTH-1:0] instruction_WB;

  logic [DATA_WIDTH-1:0] write_back_WB;

  //================================================== //
  //                 Decode Stage                      //
  //================================================== //
  instruction_memory inst_mem_inst (
    .rd_addr_i(pc_IF[INST_MEM_ADDR_WIDTH+1:2]),
    .rd_data_o(instruction_IF)
  );

  program_counter pc_cnt_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_enable(1'b1),
    .pc_i(pc_sel_IF),
    .pc_o(pc_IF)
  );

  IF_ID if_id_inst (
    .clk(clk),
    .rst_n(rst_n),

    // input from Fetch Stage
    .pc_IF(pc_IF),
    .pc_plus4_IF(pc_plus4_IF),
    .instruction_IF(instruction_IF),
    
    // output to Decode Stage
    .pc_ID(pc_ID),
    .pc_plus4_ID(pc_plus4_ID),
    .instruction_ID(instruction_ID)
  );

  //================================================== //
  //                 Decode Stage                      //
  //================================================== //
  main_control_unit main_ctrl_unit_inst (
		.opcode_i(opcode_ID), // Extract opcode from instruction
    .ImmSel_o(ImmSel_ID), // Immediate selection
		.ALUSrc1_o(ALUSrc1_ID), // ALU source selection
		.ALUSrc2_o(ALUSrc2_ID), // ALU source selection
		.ALUOp_o(ALUOp_ID), // ALU operation type
		.RegWrite_o(RegWrite_ID), // Register write enable
		.Branch_o(Branch_ID), // Branch flag
		.Jump_o(Jump_ID), // Jump flag
		.MemWrite_o(MemWrite_ID), // Memory write enable
		.MemRead_o(MemRead_ID), // Memory read enable
		.WBSel_o(WBSel_ID) // Memory to register flag
	);

	immediate_generator imm_gen_inst (
		.instruction_i(instruction_ID), // Input instruction
	  .imm_i_out(imm_i_ID),
	  .imm_s_out(imm_s_ID),
	  .imm_b_out(imm_b_ID),
	  .imm_u_out(imm_u_ID),
	  .imm_j_out(imm_j_ID)
  );

  immediate_sel imm_sel_inst (
    .ImmSel_i(ImmSel_ID),
    .imm_i_i(imm_i_ID),
    .imm_s_i(imm_s_ID),
    .imm_b_i(imm_b_ID),
    .imm_u_i(imm_u_ID),
    .imm_j_i(imm_j_ID),
    .ImmSel_o(ImmVal_ID)
  );

	register_file reg_file_inst (
		.clk(clk),
		.rst_n(rst_n),
		.we(RegWrite_WB),
		.rd_addr1_i(rs1_addr_ID), // Source register 1 (rs1)
		.rd_addr2_i(rs2_addr_ID), // Source register 2 (rs2)
		.wr_addr_i(instruction_WB[11:7]),   // Destination register (rd)
		.wr_data_i(write_back_WB),          // not yet
		.rd_data1_o(rd_data1_ID),    // Output data for rs1
		.rd_data2_o(rd_data2_ID)     // Output data for rs2
	);

	ID_EX id_ex_inst (
		.clk(clk),
		.rst_n(rst_n),

    // --- input from Decode Stage --- //
    // Control Signals
		.alu_op_ID(ALUOp_ID), // ALU operation type
		.ALUSrc1_ID(ALUSrc1_ID), // ALU source selection
		.ALUSrc2_ID(ALUSrc2_ID), // ALU source selection
		.RegWrite_ID(RegWrite_ID), // Register write enable
		.Branch_ID(Branch_ID), // Branch flag
		.Jump_ID(Jump_ID), // Jump flag
		.MemWrite_ID(MemWrite_ID), // Memory write enable
		.MemRead_ID(MemRead_ID), // Memory read enable
		.WBSel_ID(WBSel_ID), // Memory to register flag

    // Data Signals
    .pc_ID(pc_ID),
    .pc_plus4_ID(pc_plus4_ID),
		.rd_data1_ID(rd_data1_ID), // Data from rs1
		.rd_data2_ID(rd_data2_ID), // Data from rs2
		.instruction_ID(instruction_ID), // Input instruction
		.imm_ID(ImmVal_ID), // Generated immediate value
    .branch_target_adder_ID(branch_target_adder_ID),

    // --- output to Execute Stage --- //
    // Control Signals
		.alu_op_EX(ALUOp_EX), // Output ALU operation type
		.ALUSrc1_EX(ALUSrc1_EX), // Output ALU source selection
		.ALUSrc2_EX(ALUSrc2_EX), // Output ALU source selection
		.RegWrite_EX(RegWrite_EX), // Output register write enable
		.Branch_EX(Branch_EX), // Output branch flag
		.Jump_EX(Jump_EX), // Output jump flag
		.MemWrite_EX(MemWrite_EX), // Output memory write enable
		.MemRead_EX(MemRead_EX), // Output memory read enable
		.WBSel_EX(WBSel_EX), // Output memory to register flag
    
    // Data Signals
    .pc_EX(pc_EX),
    .pc_plus4_EX(pc_plus4_EX),
		.rd_data1_EX(rd_data1_EX), // Output data for rs1
		.rd_data2_EX(rd_data2_EX), // Output data for rs2
		.instruction_EX(instruction_EX), // Output instruction
		.imm_EX(ImmVal_EX), // Output immediate value
    .branch_target_adder_EX(branch_target_adder_EX)
	);
  
  //================================================== //
  //                 Execute Stage                     //
  //================================================== //

  alu_control_unit alu_ctrl_unit_inst (
      .ALUOp_i(ALUOp_EX), // Example ALU operation type
      .funct3_i(funct3_EX), // Extract funct3 from instruction
      .funct7_i(funct7_EX),    // Extract funct7 from instruction
      .ALUSel_o(ALUSel_EX)   // Output ALU selection
  );

  alu alu_inst (
      .ALUSel_i(ALUSel_EX),         // ALU selection from control unit
      .operand1_i(operand1_EX), // Example operand 1 (rs1)
      .operand2_i(operand2_EX), // Example operand 2 (rs2)
      .result_o(alu_result_EX),          // Output result from ALU
      .ZeroFlag_o(zero_flag_EX)          // Zero flag output
  );

  EX_MEM ex_mem_inst (
    .clk(clk),
    .rst_n(rst_n),

    // --- Inputs from Execute Stage ---
    // Control Signals
    .RegWrite_EX(RegWrite_EX),
    .MemWrite_EX(MemWrite_EX),
    .MemRead_EX(MemRead_EX),
    .WBSel_EX(WBSel_EX),
    .Branch_EX(Branch_EX),
    .Jump_EX(Jump_EX),

    // Data Signals
    .zero_flag_EX(zero_flag_EX),
    .alu_result_EX(alu_result_EX),
    .rd_data2_EX(rd_data2_EX),
    .pc_plus4_EX(pc_plus4_EX),
    .instruction_EX(instruction_EX),
    .branch_target_adder_EX(branch_target_adder_EX),

    // --- Outputs to Memory Stage ---
    // Control Signals
    .RegWrite_MEM(RegWrite_MEM),
    .MemWrite_MEM(MemWrite_MEM),
    .MemRead_MEM(MemRead_MEM),
    .WBSel_MEM(WBSel_MEM),
    .Branch_MEM(Branch_MEM),
    .Jump_MEM(Jump_MEM),

    // Data Signals
    .zero_flag_MEM(zero_flag_MEM),
    .alu_result_MEM(alu_result_MEM),
    .rd_data2_MEM(rd_data2_MEM),
    .pc_plus4_MEM(pc_plus4_MEM),
    .instruction_MEM(instruction_MEM),
    .branch_target_adder_MEM(branch_target_adder_MEM)
  );

  //================================================== //
  //                  Memory Stage                     //
  //================================================== //
  
  data_memory data_mem_inst (
    .clk(clk),
    .rst_n(rst_n),
    .re(MemRead_MEM),
    .we(MemWrite_MEM),
    .funct3_i(instruction_MEM[14:12]),
    .addr_i(alu_result_MEM),
    .wr_data_i(rd_data2_MEM),
    .rd_data_o(rd_data_MEM)
  );

  MEM_WB mem_wb_inst (
    .clk(clk),
    .rst_n(rst_n),
    
    // --- input from Memory Stage --- //
    // Control Signals
    .WBSel_MEM(WBSel_MEM),
    
    // Data Signals
    .pc_plus4_MEM(pc_plus4_MEM),
    .rd_data_MEM(rd_data_MEM),
    .alu_result_MEM(alu_result_MEM),
    .instruction_MEM(instruction_MEM),
    .RegWrite_MEM(RegWrite_MEM),

    // --- output to Write Back Stage --- //
    // Control Signals
    .WBSel_WB(WBSel_WB),
    
    // Data Signals
    .pc_plus4_WB(pc_plus4_WB),
    .rd_data_WB(rd_data_WB),
    .alu_result_WB(alu_result_WB),
    .instruction_WB(instruction_WB),
    .RegWrite_WB(RegWrite_WB)
  );

  //================================================== //
  //              Write Back Stage                     //
  //================================================== //
  
  write_back_sel wr_back_inst (
    .WBSel_WB(WBSel_WB),
    .alu_result_WB(alu_result_WB),
    .rd_data_WB(rd_data_WB),
    .pc_plus4_WB(pc_plus4_WB),
    .write_back_WB(write_back_WB)
  );
endmodule
