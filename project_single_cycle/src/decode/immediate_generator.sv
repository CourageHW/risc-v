`timescale 1ns/1ps

import defines::*;

module immediate_generator (
    input  logic [DATA_WIDTH-1:0] instruction_i,
    output logic [DATA_WIDTH-1:0] imm_i_out,
    output logic [DATA_WIDTH-1:0] imm_s_out,
    output logic [DATA_WIDTH-1:0] imm_b_out,
    output logic [DATA_WIDTH-1:0] imm_u_out,
    output logic [DATA_WIDTH-1:0] imm_j_out
);

    always_comb begin
        imm_i_out = { {20{instruction_i[31]}}, instruction_i[31:20] }; 
        imm_s_out = { {20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7] };
        imm_b_out = { {19{instruction_i[31]}}, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
        imm_u_out = { instruction_i[31:12], 12'b0 };
        imm_j_out = { {11{instruction_i[31]}}, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
    end
endmodule