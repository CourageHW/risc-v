`timescale 1ns/1ps

import defines::*;

module program_counter (
  input logic clk,
  input logic rst_n,
  input logic pc_enable,
  input logic [DATA_WIDTH-1:0] pc_i,
  output logic [DATA_WIDTH-1:0] pc_o
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      pc_o = '0;
    end else if (pc_enable) begin
      pc_o = pc_i;
    end
  end

endmodule
