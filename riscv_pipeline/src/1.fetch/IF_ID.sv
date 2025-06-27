`timescale 1ns/1ps

import defines::*;

module IF_ID (
  input logic clk,
  input logic rst_n,
  input logic [DATA_WIDTH-1:0] pc_IF,
  input logic [DATA_WIDTH-1:0] pc_plus4_IF,
  input logic [DATA_WIDTH-1:0] instruction_IF,

  output logic [DATA_WIDTH-1:0] pc_ID,
  output logic [DATA_WIDTH-1:0] pc_plus4_ID,
  output logic [DATA_WIDTH-1:0] instruction_ID
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      pc_ID <= '0;
      pc_plus4_ID <= '0;
      instruction_ID <= '0;
    end else begin
      pc_ID <= pc_IF;
      pc_plus4_ID <= pc_plus4_IF;
      instruction_ID <= instruction_IF;
    end
  end
endmodule
