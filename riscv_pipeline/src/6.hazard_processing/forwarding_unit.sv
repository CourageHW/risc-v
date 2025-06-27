`timescale 1ns/1ps

import defines::*;

module forwarding_unit (
  // --- Inputs from Pipeline Register --- //
  // ID/EX Stage outputs
  input logic [4:0] rs1_addr_EX,
  input logic [4:0] rs2_addr_EX,

  // EX/MEM Stage outputs
  input logic RegWrite_MEM,
  input logic [4:0] rd_addr_MEM,

  // MEM/WB Stage outputs
  input logic [4:0] rd_addr_WB,
  input logic RegWrite_WB,

  // --- Outputs to EX Stage MUXs --- //
  output fw_sel_e forwardA,
  output fw_sel_e forwardB
);
  
  // check Memory stage
  always_comb begin
    forwardA = FW_NONE;
    forwardB = FW_NONE;

    if (RegWrite_MEM && (rd_addr_MEM != 5'b0) && (rd_addr_MEM == rs1_addr_EX)) begin
      forwardA = FW_MEM_ALU;
    end
    else if (RegWrite_WB && (rd_addr_WB != 5'b0) && (rd_addr_WB == rs1_addr_EX)) begin
      forwardA = FW_WB_DATA;
    end
    
    if (RegWrite_MEM && (rd_addr_MEM != 5'b0) && (rd_addr_MEM == rs2_addr_EX)) begin
      forwardB = FW_MEM_ALU;
    end
    else if (RegWrite_WB && (rd_addr_WB != 5'b0) && (rd_addr_WB == rs2_addr_EX)) begin
      forwardB = FW_WB_DATA;
    end
  end
endmodule
