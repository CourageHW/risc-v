`timescale 1ns/1ps

import defines::*;

module main_control_unit (
    input  logic [6:0]        opcode_i,
    output logic              ALUSrc_o,
    output imm_sel_e          ImmSel_o,
    output alu_op_class_e     ALUOp_o,
    output logic              RegWrite_o,
    output logic              Branch_o,
    output logic              Jump_o,        // 새로 추가
    output logic              MemWrite_o,
    output logic              MemRead_o,
    output logic              MemtoReg_o
);

    always_comb begin
        // 기본값 설정
        ALUSrc_o   = 1'b0;
        ImmSel_o   = IMM_NONE;
        ALUOp_o    = ALUOP_NONE;
        RegWrite_o = 1'b0;
        Branch_o   = 1'b0;
        Jump_o     = 1'b0;
        MemWrite_o = 1'b0;
        MemRead_o  = 1'b0;
        MemtoReg_o = 1'b0;

        case (opcode_i)
            OPCODE_RTYPE: begin  // R-type: add, sub, and, or, xor, sll, srl, sra, slt, sltu
                ALUSrc_o   = 1'b0;    // 레지스터 사용
                ImmSel_o   = IMM_TYPE_R;
                ALUOp_o    = ALUOP_RTYPE;
                RegWrite_o = 1'b1;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // ALU 결과를 레지스터에 쓰기
            end

            OPCODE_ITYPE: begin  // I-type: addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                ALUSrc_o   = 1'b1;    // immediate 사용
                ImmSel_o   = IMM_TYPE_I;
                ALUOp_o    = ALUOP_ITYPE_ARITH;
                RegWrite_o = 1'b1;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // ALU 결과를 레지스터에 쓰기
            end

            OPCODE_LOAD: begin   // Load: lb, lh, lw, lbu, lhu
                ALUSrc_o   = 1'b1;    // immediate 사용 (주소 계산)
                ImmSel_o   = IMM_TYPE_I;
                ALUOp_o    = ALUOP_MEM_ADDR;
                RegWrite_o = 1'b1;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b1;
                MemtoReg_o = 1'b1;    // 메모리에서 읽은 데이터를 레지스터에 쓰기
            end

            OPCODE_STORE: begin  // Store: sb, sh, sw
                ALUSrc_o   = 1'b1;    // immediate 사용 (주소 계산)
                ImmSel_o   = IMM_TYPE_S;
                ALUOp_o    = ALUOP_MEM_ADDR;
                RegWrite_o = 1'b0;    // 레지스터에 쓰지 않음
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b1;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;
            end

            OPCODE_BRANCH: begin // Branch: beq, bne, blt, bge, bltu, bgeu
                ALUSrc_o   = 1'b0;    // 레지스터 비교
                ImmSel_o   = IMM_TYPE_B;
                ALUOp_o    = ALUOP_BRANCH;  // 사실 분기는 별도 비교기 사용
                RegWrite_o = 1'b0;    // 레지스터에 쓰지 않음
                Branch_o   = 1'b1;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;
            end

            OPCODE_JAL: begin    // JAL
                ALUSrc_o   = 1'b1;    // immediate 사용
                ImmSel_o   = IMM_TYPE_J;
                ALUOp_o    = ALUOP_JUMP;
                RegWrite_o = 1'b1;    // return address 저장
                Branch_o   = 1'b0;
                Jump_o     = 1'b1;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // return address (PC+4) 저장
            end

            OPCODE_JALR: begin   // JALR
                ALUSrc_o   = 1'b1;    // immediate 사용
                ImmSel_o   = IMM_TYPE_I;
                ALUOp_o    = ALUOP_JUMP;
                RegWrite_o = 1'b1;    // return address 저장
                Branch_o   = 1'b0;
                Jump_o     = 1'b1;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // return address (PC+4) 저장
            end

            OPCODE_LUI: begin    // LUI
                ALUSrc_o   = 1'b1;    // immediate 사용
                ImmSel_o   = IMM_TYPE_U;
                ALUOp_o    = ALUOP_LUI;
                RegWrite_o = 1'b1;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // immediate 값을 레지스터에 쓰기
            end

            OPCODE_AUIPC: begin  // AUIPC
                ALUSrc_o   = 1'b1;    // immediate 사용
                ImmSel_o   = IMM_TYPE_U;
                ALUOp_o    = ALUOP_JUMP;  // PC + immediate
                RegWrite_o = 1'b1;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;    // PC + immediate 결과를 레지스터에 쓰기
            end

            default: begin
                // NOP 또는 미지원 명령어
                ALUSrc_o   = 1'b0;
                ImmSel_o   = IMM_NONE;
                ALUOp_o    = ALUOP_NONE;
                RegWrite_o = 1'b0;
                Branch_o   = 1'b0;
                Jump_o     = 1'b0;
                MemWrite_o = 1'b0;
                MemRead_o  = 1'b0;
                MemtoReg_o = 1'b0;
            end
        endcase
    end

endmodule