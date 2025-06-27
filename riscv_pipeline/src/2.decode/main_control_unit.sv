`timescale 1ns/1ps

import defines::*;

// 모듈 이름을 main_control_unit으로 변경하여 일관성을 유지하는 것을 추천합니다.
module main_control_unit (
    input  logic [6:0]    opcode_i,

    // 제어 신호 출력 포트
    output logic          RegWrite_o,
    output wb_sel_e       WBSel_o,
    output logic          MemRead_o,
    output logic          MemWrite_o,
    output logic          Branch_o,
    output logic          Jump_o,      // JAL, JALR을 위한 점프 신호

    // ALU 소스 제어를 위한 두 개의 출력 신호
    output logic          ALUSrc1_o,   // ALU Operand 1 선택 (0: rs1, 1: PC)
    output logic          ALUSrc2_o,   // ALU Operand 2 선택 (0: rs2, 1: imm)

    // ALU 연산 종류 및 Immediate 타입 선택 신호
    output alu_op_e       ALUOp_o,
    output imm_sel_e      ImmSel_o
);

    always_comb begin
        // --- 1. 모든 신호를 안전한 기본값으로 초기화 ---
        // 대부분의 명령어는 rs1과 rs2를 사용하므로, 이것이 기본값입니다.
        RegWrite_o = 1'b0;
        WBSel_o    = WB_NONE;
        MemRead_o  = 1'b0;
        MemWrite_o = 1'b0;
        Branch_o   = 1'b0;
        Jump_o     = 1'b0;
        ALUSrc1_o  = 1'b0; // Default: Select rs1
        ALUSrc2_o  = 1'b0; // Default: Select rs2
        ALUOp_o    = ALUOP_NONE;
        ImmSel_o   = IMM_TYPE_R;

        // --- 2. Opcode에 따라 필요한 신호만 활성화 ---
        case (opcode_i)
            OPCODE_RTYPE: begin
                RegWrite_o = 1'b1;
                ALUOp_o    = ALUOP_RTYPE;
                WBSel_o    = WB_ALU;
                // ALUSrc1=0 (rs1), ALUSrc2=0 (rs2) -> 기본값 사용
            end

            OPCODE_ITYPE: begin
                RegWrite_o = 1'b1;
                ALUSrc2_o  = 1'b1; // imm 사용
                ALUOp_o    = ALUOP_ITYPE_ARITH;
                ImmSel_o   = IMM_TYPE_I;
                WBSel_o    = WB_ALU;
            end

            OPCODE_LOAD: begin
                RegWrite_o = 1'b1;
                ALUSrc2_o  = 1'b1; // imm 사용 (주소 계산)
                WBSel_o    = WB_MEM;
                MemRead_o  = 1'b1;
                ALUOp_o    = ALUOP_MEM_ADDR;
                ImmSel_o   = IMM_TYPE_I;
            end

            OPCODE_STORE: begin
                ALUSrc2_o  = 1'b1; // imm 사용 (주소 계산)
                MemWrite_o = 1'b1;
                ALUOp_o    = ALUOP_MEM_ADDR;
                ImmSel_o   = IMM_TYPE_S;
                WBSel_o    = WB_NONE;
            end

            OPCODE_BRANCH: begin
                // 비교 연산은 rs1, rs2 사용 (ALUSrc1=0, ALUSrc2=0)
                // 하지만 branch target 주소 계산은 PC + imm (별도 Adder 사용 가정)
                Branch_o   = 1'b1;
                ALUOp_o    = ALUOP_BRANCH;
                ImmSel_o   = IMM_TYPE_B;
                WBSel_o    = WB_NONE;
            end
            
            OPCODE_LUI: begin
                RegWrite_o = 1'b1;
                ALUSrc2_o  = 1'b1; // imm 사용
                ALUOp_o    = ALUOP_LUI;
                ImmSel_o   = IMM_TYPE_U;
                WBSel_o    = WB_ALU;
            end

            OPCODE_AUIPC: begin
                RegWrite_o = 1'b1;
                ALUSrc1_o  = 1'b1; // PC 사용
                ALUSrc2_o  = 1'b1; // imm 사용
                ALUOp_o    = ALUOP_JUMP;
                ImmSel_o   = IMM_TYPE_U;
                WBSel_o    = WB_ALU;
            end

            OPCODE_JAL: begin
                WBSel_o    = WB_PC4;
                RegWrite_o = 1'b1;
                Jump_o     = 1'b1; // Jump 신호 활성화
                // PC+4는 별도 Adder에서 계산, 레지스터에 저장
                // 다음 PC 계산은 이 제어 유닛의 책임이 아님
            end

            OPCODE_JALR: begin
                WBSel_o    = WB_PC4;
                RegWrite_o = 1'b1;
                Jump_o     = 1'b1;
                // 다음 PC 계산은 rs1 + imm (ALU가 수행)
                ALUSrc2_o  = 1'b1;
                ALUOp_o    = ALUOP_JUMP;
                ImmSel_o   = IMM_TYPE_I;
            end

            default: ; // 정의되지 않은 opcode는 기본값 유지
        endcase
    end

endmodule

