`timescale 1ns/1ps
import defines::*;

module tb_main_control_unit;

    // =========================================
    // 1. 신호 선언 및 DUT 인스턴스화
    // =========================================
    logic [6:0]      opcode_i;
    logic            RegWrite_o, ALUSrc_o, MemtoReg_o, MemRead_o, MemWrite_o, Branch_o;
    alu_op_class_e   ALUOp_o;
    imm_sel_e        ImmSel_o;

    main_control_unit dut (
        .opcode_i(opcode_i),
        .RegWrite_o(RegWrite_o),
        .ALUSrc_o(ALUSrc_o),
        .MemtoReg_o(MemtoReg_o),
        .MemRead_o(MemRead_o),
        .MemWrite_o(MemWrite_o),
        .Branch_o(Branch_o),
        .ALUOp_o(ALUOp_o),
        .ImmSel_o(ImmSel_o)
    );

    // =========================================
    // 2. 검증을 위한 헬퍼 태스크 (struct 대신 개별 인자 사용)
    // =========================================
    task run_test(
        input logic [6:0]       opcode,
        input logic             exp_RegWrite,
        input logic             exp_ALUSrc,
        input logic             exp_MemtoReg,
        input logic             exp_MemRead,
        input logic             exp_MemWrite,
        input logic             exp_Branch,
        input alu_op_class_e    exp_ALUOp,
        input imm_sel_e         exp_ImmSel,
        input string            test_name
    );
        $display("----------------------------------------");
        $display("Running test: %s (Opcode: %7b)", test_name, opcode);
        
        opcode_i = opcode;
        #1; // 조합회로 안정화 시간

        assert (RegWrite_o === exp_RegWrite) else $fatal(1, "[FAIL] %s: RegWrite mismatch", test_name);
        assert (ALUSrc_o   === exp_ALUSrc)   else $fatal(1, "[FAIL] %s: ALUSrc mismatch", test_name);
        // MemtoReg는 Don't care('x') 일 수 있으므로, '===' 대신 '==' 비교로 경고를 피할 수 있습니다.
        if (exp_MemtoReg !== 1'bx) assert (MemtoReg_o === exp_MemtoReg) else $fatal(1, "[FAIL] %s: MemtoReg mismatch", test_name);
        assert (MemRead_o  === exp_MemRead)  else $fatal(1, "[FAIL] %s: MemRead mismatch", test_name);
        assert (MemWrite_o === exp_MemWrite) else $fatal(1, "[FAIL] %s: MemWrite mismatch", test_name);
        assert (Branch_o   === exp_Branch)   else $fatal(1, "[FAIL] %s: Branch mismatch", test_name);
        assert (ALUOp_o    === exp_ALUOp)    else $fatal(1, "[FAIL] %s: ALUOp mismatch", test_name);
        assert (ImmSel_o   === exp_ImmSel)   else $fatal(1, "[FAIL] %s: ImmSel mismatch", test_name);

        $display("[PASS] %s", test_name);
    endtask

    // =========================================
    // 3. 메인 테스트 시퀀스 (struct 할당 대신 직접 값 전달)
    // =========================================
    initial begin
        $display("INFO: Main Control Unit Test Started.");
        
        //            Opcode,         RegW, ALUSrc, Mem2R, MemR, MemW, Br, ALUOp,             ImmSel,      Test Name
        run_test(OPCODE_RTYPE,      1,    0,      0,     0,    0,    0,  ALUOP_RTYPE,       IMM_TYPE_R,  "R-Type");
        run_test(OPCODE_LOAD,       1,    1,      1,     1,    0,    0,  ALUOP_MEM_ADDR,    IMM_TYPE_I,  "Load");
        run_test(OPCODE_STORE,      0,    1,      1'bx,  0,    1,    0,  ALUOP_MEM_ADDR,    IMM_TYPE_S,  "Store");
        run_test(OPCODE_BRANCH,     0,    0,      1'bx,  0,    0,    1,  ALUOP_BRANCH,      IMM_TYPE_B,  "Branch");
        run_test(OPCODE_ITYPE,      1,    1,      0,     0,    0,    0,  ALUOP_ITYPE_ARITH, IMM_TYPE_I,  "I-Type Arith");
        run_test(OPCODE_JAL,        1,    0,      0,     0,    0,    0,  ALUOP_JUMP,        IMM_TYPE_J,  "JAL");
        run_test(OPCODE_LUI,        1,    1,      0,     0,    0,    0,  ALUOP_LUI,         IMM_TYPE_U,  "LUI");
        
        $display("----------------------------------------");
        $display("\n==============================================");
        $display("  [SUCCESS] All Main Control Unit tests passed!");
        $display("==============================================");
        $finish;
    end

endmodule
