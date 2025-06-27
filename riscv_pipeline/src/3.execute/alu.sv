`timescale 1ns/1ps

import defines::*;

module alu (
    input  alu_sel_e              ALUSel_i,
    input  logic [DATA_WIDTH-1:0] operand1_i,
    input  logic [DATA_WIDTH-1:0] operand2_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic                  ZeroFlag_o
);

    always_comb begin
        unique case (ALUSel_i)
            ALU_ADD     : result_o = operand1_i + operand2_i;
            ALU_SUB     : result_o = operand1_i - operand2_i;
            ALU_AND     : result_o = operand1_i & operand2_i;
            ALU_OR      : result_o = operand1_i | operand2_i;
            ALU_XOR     : result_o = operand1_i ^ operand2_i;
            ALU_SLL     : result_o = operand1_i << operand2_i[4:0];
            ALU_SRL     : result_o = operand1_i >> operand2_i[4:0];
            ALU_SRA     : result_o = $signed(operand1_i) >>> operand2_i[4:0];
            ALU_SLT     : result_o = ($signed(operand1_i) < $signed(operand2_i)) ? 32'd1 : 32'd0;
            ALU_SLTU    : result_o = (operand1_i < operand2_i) ? 32'd1 : 32'd0;
            ALU_PASS_B  : result_o = operand2_i;
            default     : result_o = 'x; // Undefined operation
        endcase
    end

    assign ZeroFlag_o = (result_o == '0);

endmodule