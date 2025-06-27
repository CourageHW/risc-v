`timescale 1ns/1ps

import defines::*;

module alu_control_unit (
    input alu_op_class_e ALUOp_i,
    input logic  [2:0]   funct3_i,
    input logic  [6:0]   funct7_i,

    output alu_control_e ALUControl_o
);

    always_comb begin
        ALUControl_o = ALU_X;

        case (ALUOp_i)
            ALUOP_MEM_ADDR      : ALUControl_o = ALU_ADD;
            ALUOP_BRANCH        : ALUControl_o = ALU_SUB;
            ALUOP_LUI           : ALUControl_o = ALU_PASS_B;
            ALUOP_JUMP          : ALUControl_o = ALU_ADD;
            ALUOP_RTYPE         : begin
                case (funct3_i)
                    FUNCT3_ADD_SUB  : begin
                        if      (funct7_i == FUNCT7_ADD) ALUControl_o = ALU_ADD;
                        else if (funct7_i == FUNCT7_SUB) ALUControl_o = ALU_SUB;
                        else                             ALUControl_o = ALU_X;
                    end
                    FUNCT3_SLL      : ALUControl_o = ALU_SLL;
                    FUNCT3_SLT      : ALUControl_o = ALU_SLT;
                    FUNCT3_SLTU     : ALUControl_o = ALU_SLTU;
                    FUNCT3_XOR      : ALUControl_o = ALU_XOR;
                    FUNCT3_SRL_SRA  : begin
                        if      (funct7_i == FUNCT7_SRL) ALUControl_o = ALU_SRL;
                        else if (funct7_i == FUNCT7_SRA) ALUControl_o = ALU_SRA;
                        else                             ALUControl_o = ALU_X;
                    end
                    FUNCT3_OR       : ALUControl_o = ALU_OR;
                    FUNCT3_AND      : ALUControl_o = ALU_AND;
                    default         : ALUControl_o = ALU_X;
                endcase
            end

            ALUOP_ITYPE_ARITH   : begin
                case (funct3_i)
                    FUNCT3_ADD_SUB     : ALUControl_o = ALU_ADD;  // addi
                    FUNCT3_SLL         : ALUControl_o = ALU_SLL;  // slli
                    FUNCT3_SLT         : ALUControl_o = ALU_SLT;  // slti
                    FUNCT3_SLTU        : ALUControl_o = ALU_SLTU; // sltui
                    FUNCT3_XOR         : ALUControl_o = ALU_XOR;  // xori
                    FUNCT3_SRL_SRA     : begin
                       if      (funct7_i == FUNCT7_SRLI) ALUControl_o = ALU_SRL; // srli
                       else if (funct7_i == FUNCT7_SRAI) ALUControl_o = ALU_SRA; // srai
                       else                              ALUControl_o = ALU_X;
                    end
                    FUNCT3_OR          : ALUControl_o = ALU_OR;   // ori
                    FUNCT3_AND         : ALUControl_o = ALU_AND;  // andi
                    default            : ALUControl_o = ALU_X;            
                endcase
            end
            default             : ALUControl_o = ALU_X;
        endcase
    end

endmodule