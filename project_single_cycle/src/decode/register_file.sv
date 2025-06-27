`timescale 1ns/1ps

import defines::*;

module register_file (
    input logic clk,
    input logic rst_n,
    input logic we,
    input logic [ADDR_WIDTH-1:0] rd_addr1_i, // read1 address
    input logic [ADDR_WIDTH-1:0] rd_addr2_i, // read2 address
    input logic [ADDR_WIDTH-1:0] wr_addr_i,  // write address
    input logic [DATA_WIDTH-1:0] wr_data_i,

    output logic [DATA_WIDTH-1:0] rd_data1_o,
    output logic [DATA_WIDTH-1:0] rd_data2_o
);

    logic [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                registers[i] <= '0;
            end
        end else if (we) begin
            if (wr_addr_i != '0) begin
                registers[wr_addr_i] <= wr_data_i;
            end
        end
    end

    always_comb begin
        rd_data1_o = (rd_addr1_i == '0) ? '0 : registers[rd_addr1_i];
        rd_data2_o = (rd_addr2_i == '0) ? '0 : registers[rd_addr2_i];
    end
endmodule