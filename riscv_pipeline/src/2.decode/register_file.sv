`timescale 1ns/1ps

import defines::*;

module register_file (
    input logic clk,
    input logic rst_n,
    input logic we_WB,
    input logic [ADDR_WIDTH-1:0] wr_addr_WB,  // write address
    input logic [DATA_WIDTH-1:0] wr_data_WB,

    input logic [ADDR_WIDTH-1:0] rd_addr1_i, // read1 address
    input logic [ADDR_WIDTH-1:0] rd_addr2_i, // read2 address

    output logic [DATA_WIDTH-1:0] rd_data1_o,
    output logic [DATA_WIDTH-1:0] rd_data2_o
);

    logic [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];

    // write
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                registers[i] <= '0;
            end
        end else if (we_WB && wr_addr_WB != '0) begin
            registers[wr_addr_WB] <= wr_data_WB;
        end
    end

    // read
    always_comb begin
      if (we_WB && (wr_addr_WB != '0) && (wr_addr_WB == rd_addr1_i)) begin
        rd_data1_o = wr_data_WB;
      end else begin
        rd_data1_o = (rd_addr1_i == '0) ? '0 : registers[rd_addr1_i];
      end


      if (we_WB && (wr_addr_WB != '0) && (wr_addr_WB == rd_addr2_i)) begin
        rd_data2_o = wr_data_WB;
      end else begin
        rd_data2_o = (rd_addr2_i == '0) ? '0 : registers[rd_addr2_i];
      end
    end
endmodule
