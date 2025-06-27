`timescale 1ns/1ps

import defines::*;

module ex_core (
    input  alu_op_class_e ALUOp_i,
    input  logic [2:0]    funct3_i,
    input  logic [6:0]    funct7_i,
    input  logic [DATA_WIDTH-1:0] operand1_i,
    input  logic [DATA_WIDTH-1:0] operand2_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic                  ZeroFlag_o
);
    alu_control_e ALUFunc_w;

    alu_control_unit alu_ctrl_inst (
        .ALUOp_i(ALUOp_i),
        .funct3_i(funct3_i),
        .funct7_i(funct7_i),
        .ALUControl_o(ALUFunc_w)
    );

    alu alu_inst (
        .ALUControl_i(ALUFunc_w),
        .operand1_i(operand1_i),
        .operand2_i(operand2_i),
        .result_o(result_o),
        .ZeroFlag_o(ZeroFlag_o)
    );
endmodule