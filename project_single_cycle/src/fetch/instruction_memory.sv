`timescale 1ns/1ps

import defines::*;

module instruction_memory (
    input  logic clk,
    input  logic [INST_MEM_ADDR_WIDTH-1:0] rd_addr,
    output logic [DATA_WIDTH-1:0] rd_data
);

    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] inst_mem [0:INST_MEM_DEPTH-1];

    initial begin
        $readmemh("program3.mem", inst_mem);
    end

    //always_ff @(posedge clk) begin
    //    rd_data <= inst_mem[rd_addr];
    //end
    always_comb begin
        rd_data = inst_mem[rd_addr];
    end
endmodule