`timescale 1ns/1ps

import defines::*;

module core (
    input  logic clk,
    input  logic rst_n
);
    //// Fetch
    // program counter
    logic [DATA_WIDTH-1:0] pc_i;
    logic [DATA_WIDTH-1:0] pc_o;
    logic [DATA_WIDTH-1:0] pc_plus4_w;
    logic [DATA_WIDTH-1:0] branch_target_addr_w;
    logic [DATA_WIDTH-1:0] jump_target_addr_w;
    logic                  branch_decision_w;
    logic                  jump_decision_w;

    // instruction memory
    logic [DATA_WIDTH-1:0] instruction_w;
    
    //// Decode
    logic [6:0] opcode_w;
    logic [2:0] funct3_w;
    logic [6:0] funct7_w;


    // main control unit
    logic          ALUSrc_w;
    logic          RegWrite_w;
    logic          Branch_w;
    logic          Jump_w;
    logic          MemWrite_w;
    logic          MemRead_w;
    logic          MemtoReg_w;
    logic          PCSrc_w;
    imm_sel_e      ImmSel_w;
    alu_op_class_e ALUOp_w;

    // immediate generator
    logic [DATA_WIDTH-1:0] imm_i_wire;
    logic [DATA_WIDTH-1:0] imm_s_wire;
    logic [DATA_WIDTH-1:0] imm_b_wire;
    logic [DATA_WIDTH-1:0] imm_u_wire;
    logic [DATA_WIDTH-1:0] imm_j_wire;

    logic [DATA_WIDTH-1:0] imm_mux_o;

    // register file
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [DATA_WIDTH-1:0] rd_data1_w;
    logic [DATA_WIDTH-1:0] rd_data2_w;

    //// Execute
    // ALU Control unit
    alu_control_e ALUFunc_w;
    logic [DATA_WIDTH-1:0] alu_operand1_w;
    logic [DATA_WIDTH-1:0] alu_operand2_w;
    logic [DATA_WIDTH-1:0] alu_result_w;
    logic                  alu_zero_flag_w;

    logic branch_taken_w;

    //// Memory
    // Data Memory
    logic [DATA_WIDTH-1:0] load_unit_out_w;

    //// Write Back
    logic [DATA_WIDTH-1:0] mem_read_data_w;
    logic [DATA_WIDTH-1:0] write_back_data_w;
    logic [DATA_WIDTH-1:0] return_addr_w;

    // Fetch Stage
    program_counter pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_we(1'b1),
        .pc_i(pc_i),
        .pc_o(pc_o)
    );

    instruction_memory inst_mem_inst (
        .clk(clk),
        .rd_addr(pc_o[INST_MEM_ADDR_WIDTH+1:2]),
        .rd_data(instruction_w)
    );

    assign pc_plus4_w           = pc_o + 32'd4;
    assign branch_target_addr_w = pc_o + imm_mux_o;
    assign jump_target_addr_w   = (opcode_w == OPCODE_JAL) ? (pc_o + imm_mux_o) : (rd_data1_w + imm_mux_o) & ~32'h1; // JAL : JALR
    assign return_addr_w        = pc_plus4_w;

    assign jump_decision_w      = Jump_w;
    assign branch_decision_w    = Branch_w & alu_zero_flag_w;
    assign pc_i                 = (branch_decision_w) ? branch_target_addr_w : pc_plus4_w;

    // Decode Stage
    assign opcode_w = instruction_w[6:0];
    assign rd_addr  = instruction_w[11:7];
    assign funct3_w = instruction_w[14:12];
    assign rs1_addr = instruction_w[19:15];
    assign rs2_addr = instruction_w[24:20];
    assign funct7_w = instruction_w[31:25];

    main_control_unit main_ctrl_inst (
        .opcode_i   (opcode_w),
        .ALUSrc_o   (ALUSrc_w),
        .ImmSel_o   (ImmSel_w),
        .ALUOp_o    (ALUOp_w),
        .RegWrite_o (RegWrite_w),
        .Branch_o   (Branch_w),
        .Jump_o     (Jump_w),
        .MemWrite_o (MemWrite_w),
        .MemRead_o  (MemRead_w),
        .MemtoReg_o (MemtoReg_w)
    );

    immediate_generator imm_gen_inst (
        .instruction_i(instruction_w),
        .imm_i_out    (imm_i_wire),
        .imm_s_out    (imm_s_wire),
        .imm_b_out    (imm_b_wire),
        .imm_u_out    (imm_u_wire),
        .imm_j_out    (imm_j_wire)
    );

    register_file reg_file_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .we         (RegWrite_w),
        .rd_addr1_i (rs1_addr),
        .rd_addr2_i (rs2_addr),
        .wr_addr_i  (rd_addr),
        .wr_data_i  (write_back_data_w),
        .rd_data1_o (rd_data1_w),
        .rd_data2_o (rd_data2_w)
    );

    always_comb begin
        case(ImmSel_w)
            IMM_TYPE_R: imm_mux_o = 32'd0;
            IMM_TYPE_I: imm_mux_o = imm_i_wire; 
            IMM_TYPE_S: imm_mux_o = imm_s_wire;
            IMM_TYPE_B: imm_mux_o = imm_b_wire;
            IMM_TYPE_U: imm_mux_o = imm_u_wire;
            IMM_TYPE_J: imm_mux_o = imm_j_wire;
            default   : imm_mux_o = 'x;
        endcase
    end

    assign alu_operand1_w = rd_data1_w;
    assign alu_operand2_w = (ALUSrc_w) ? imm_mux_o : rd_data2_w;
    // Execute Stage
    alu_control_unit alu_ctrl_inst (
        .ALUOp_i      (ALUOp_w),
        .funct3_i     (funct3_w),
        .funct7_i     (funct7_w),
        .ALUControl_o (ALUFunc_w)
    );

    alu alu_inst (
        .ALUControl_i   (ALUFunc_w),
        .operand1_i     (alu_operand1_w),
        .operand2_i     (alu_operand2_w),
        .result_o       (alu_result_w),
        .ZeroFlag_o     (alu_zero_flag_w)
    );

    branch_comparator branch_comp_inst (
        .funct3_i       (funct3_w),
        .Branch_i       (Branch_w),
        .operand1_i     (rd_data1_w),
        .operand2_i     (rd_data2_w),
        .branch_taken_o (branch_taken_w)
    );

    logic [DATA_WIDTH-1:0] store_data_w;

    // rd_data2_w를 주소(alu_result_w)에 맞게 정렬하는 로직 추가
    always_comb begin
        case (alu_result_w[1:0])
            2'b00:  store_data_w = rd_data2_w;
            2'b01:  store_data_w = {rd_data2_w[23:0], 8'b0}; // 8비트 왼쪽 시프트
            2'b10:  store_data_w = {rd_data2_w[15:0], 16'b0}; // 16비트 왼쪽 시프트
            2'b11:  store_data_w = {rd_data2_w[7:0], 24'b0}; // 24비트 왼쪽 시프트
            default: store_data_w = rd_data2_w;
        endcase
    end

    // Memory Stage
    data_memory data_mem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .we(MemWrite_w),
        .funct3_i(funct3_w),
        .addr_i(alu_result_w),
        .wr_data_i(store_data_w),
        .rd_data_o(mem_read_data_w)
    );
    


    always_comb begin
        logic [15:0] halfword_selected;
        logic [7:0]  byte_selected;
        logic        unaligned_access;
        unaligned_access = 1'b0;

        case(alu_result_w[1:0])
            2'b00: begin
                byte_selected     = mem_read_data_w[7:0];
                halfword_selected = mem_read_data_w[15:0];
            end
            2'b01: begin
                byte_selected     = mem_read_data_w[15:8];
                halfword_selected = 16'b0;  // 정렬되지 않은 접근
                unaligned_access  = (funct3_w == FUNCT3_LH || funct3_w == FUNCT3_LHU);
            end
            2'b10: begin
                byte_selected     = mem_read_data_w[23:16];
                halfword_selected = mem_read_data_w[31:16];
            end
            2'b11: begin
                byte_selected     = mem_read_data_w[31:24];
                halfword_selected = 16'b0;  // 정렬되지 않은 접근
                unaligned_access  = (funct3_w == FUNCT3_LH || funct3_w == FUNCT3_LHU);
            end
        endcase

        if (unaligned_access) begin
            load_unit_out_w = 32'b0;  // 또는 예외 발생 신호
        end else begin
            case (funct3_w)
                FUNCT3_LB :  load_unit_out_w = {{24{byte_selected[7]}}, byte_selected};          
                FUNCT3_LBU:  load_unit_out_w = {24'b0, byte_selected};                           
                FUNCT3_LH :  load_unit_out_w = {{16{halfword_selected[15]}}, halfword_selected}; 
                FUNCT3_LHU:  load_unit_out_w = {16'b0, halfword_selected};                       
                FUNCT3_LW :  load_unit_out_w = mem_read_data_w;                                  
                default   :  load_unit_out_w = mem_read_data_w;                                  
            endcase
        end
    end

    // Write Back
    always_comb begin
        if (Jump_w) begin
            write_back_data_w = return_addr_w;  // JAL/JALR은 return address 저장
        end else if (MemtoReg_w) begin
            write_back_data_w = load_unit_out_w;  // Load 명령어
        end else begin
            write_back_data_w = alu_result_w;     // 산술/논리 연산 결과
        end
    end
endmodule