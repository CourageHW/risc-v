`timescale 1ns/1ps

import defines::*;

module MEM_WB (
  input logic clk,
  input logic rst_n,

  input logic [DATA_WIDTH-1:0] pc_plus4_MEM,
  input logic [DATA_WIDTH-1:0] rd_data_MEM,
  input logic [DATA_WIDTH-1:0] alu_result_MEM,
  input logic [DATA_WIDTH-1:0] instruction_MEM,
  input logic RegWrite_MEM,
  input wb_sel_e WBSel_MEM,

  output logic [DATA_WIDTH-1:0] pc_plus4_WB,
  output logic [DATA_WIDTH-1:0] rd_data_WB,
  output logic [DATA_WIDTH-1:0] alu_result_WB,
  output logic [DATA_WIDTH-1:0] instruction_WB,
  output logic RegWrite_WB,
  output wb_sel_e WBSel_WB
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      pc_plus4_WB <= '0;
      rd_data_WB  <= '0;
      alu_result_WB <= '0;
      instruction_WB <= '0;
      RegWrite_WB <= 1'b0;
      WBSel_WB <= WB_NONE;
    end else begin
      pc_plus4_WB <= pc_plus4_MEM;
      rd_data_WB <= rd_data_MEM;
      alu_result_WB <= alu_result_MEM;
      instruction_WB <= instruction_MEM;
      RegWrite_WB <= RegWrite_MEM;
      WBSel_WB <= WBSel_MEM;
    end
  end

endmodule
