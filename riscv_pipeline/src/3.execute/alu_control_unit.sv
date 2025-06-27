`timescale 1ns/1ps

import defines::*;

module alu_control_unit (
    input  alu_op_e    ALUOp_i,
    input  logic [2:0] funct3_i, // instruction[14:12]
    input  logic       funct7_i, // instruction[30]
    output alu_sel_e   ALUSel_o
);

    always_comb begin
        ALUSel_o = ALU_X;

        unique case (ALUOp_i)
            ALUOP_MEM_ADDR: ALUSel_o = ALU_ADD;    // lw, sw
            ALUOP_BRANCH  : ALUSel_o = ALU_SUB;    // beq, bne, blt, bge, bltu, bgeu
            ALUOP_LUI     : ALUSel_o = ALU_PASS_B; // lui
            ALUOP_JUMP    : ALUSel_o = ALU_ADD;    // jal, jalr

            ALUOP_RTYPE: begin
                unique case (funct3_i)
                    FUNCT3_ADD_SUB: ALUSel_o = (funct7_i == FUNCT7_ADD) ? ALU_ADD : ALU_SUB;
                    FUNCT3_AND    : ALUSel_o = ALU_AND;
                    FUNCT3_OR     : ALUSel_o = ALU_OR;
                    FUNCT3_XOR    : ALUSel_o = ALU_XOR;
                    FUNCT3_SLL    : ALUSel_o = ALU_SLL;
                    FUNCT3_SRL_SRA: ALUSel_o = (funct7_i == FUNCT7_SRL) ? ALU_SRL : ALU_SRA;
                    FUNCT3_SLT    : ALUSel_o = ALU_SLT;
                    FUNCT3_SLTU   : ALUSel_o = ALU_SLTU;
                    default       : ALUSel_o = ALU_X;
                endcase
            end

            // I-type arithmetic instructions
            ALUOP_ITYPE_ARITH: begin
                unique case (funct3_i)
                    FUNCT3_ADD_SUB: ALUSel_o = ALU_ADD;  // addi
                    FUNCT3_AND    : ALUSel_o = ALU_AND;  // andi
                    FUNCT3_OR     : ALUSel_o = ALU_OR;   // ori
                    FUNCT3_XOR    : ALUSel_o = ALU_XOR;  // xori
                    FUNCT3_SLL    : ALUSel_o = ALU_SLL;  // slli
                    FUNCT3_SRL_SRA: ALUSel_o = (funct7_i == FUNCT7_SRLI) ? ALU_SRL : ALU_SRA; // srli, srai
                    FUNCT3_SLT    : ALUSel_o = ALU_SLT;  // slti
                    FUNCT3_SLTU   : ALUSel_o = ALU_SLTU; // sltiu
                    default       : ALUSel_o = ALU_X;
                endcase
            end

            default: ALUSel_o = ALU_X; // Default case for unsupported ALUOp
        endcase
    end

endmodule
