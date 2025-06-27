`timescale 1ns / 1ps

import defines::*;

module ID_EX (
	input logic clk,
	input logic rst_n,
	input alu_op_e alu_op_ID,
	input logic ALUSrc1_ID,
  input logic ALUSrc2_ID,
	input logic RegWrite_ID,
  input logic Branch_ID,
  input logic Jump_ID,
  input logic MemWrite_ID,
  input logic MemRead_ID,
  input wb_sel_e WBSel_ID,
  input logic [DATA_WIDTH-1:0] pc_ID,
  input logic [DATA_WIDTH-1:0] pc_plus4_ID,
	input logic [DATA_WIDTH-1:0] rd_data1_ID,
	input logic [DATA_WIDTH-1:0] rd_data2_ID,
	input logic [DATA_WIDTH-1:0] instruction_ID,
	input logic [DATA_WIDTH-1:0] imm_ID,
  input logic [DATA_WIDTH-1:0] branch_target_adder_ID,

	output alu_op_e alu_op_EX,
	output logic ALUSrc1_EX,
  output logic ALUSrc2_EX,
	output logic RegWrite_EX,
  output logic Branch_EX,
  output logic Jump_EX,
  output logic MemWrite_EX,
  output logic MemRead_EX,
  output wb_sel_e WBSel_EX,
  output logic [DATA_WIDTH-1:0] pc_EX,
  output logic [DATA_WIDTH-1:0] pc_plus4_EX,
	output logic [DATA_WIDTH-1:0] rd_data1_EX,
	output logic [DATA_WIDTH-1:0] rd_data2_EX,
	output logic [DATA_WIDTH-1:0] instruction_EX,
	output logic [DATA_WIDTH-1:0] imm_EX,
  output logic [DATA_WIDTH-1:0] branch_target_adder_EX
);

	always_ff @(posedge clk) begin
		if (!rst_n) begin
      pc_EX <= '0;
      pc_plus4_EX <= '0;
			alu_op_EX <= ALUOP_RTYPE; // Default to R-type operation
			ALUSrc1_EX <= 1'b0; // Default ALU source selection
			ALUSrc2_EX <= 1'b0; // Default ALU source selection
			RegWrite_EX <= 1'b0; // Default register write disable
			Branch_EX <= 1'b0; // Default branch disable
			Jump_EX <= 1'b0; // Default jump disable
			MemWrite_EX <= 1'b0; // Default memory write disable
			MemRead_EX <= 1'b0; // Default memory read disable
			WBSel_EX <= 1'b0; // Default memory to register disable
			rd_data1_EX <= '0;
			rd_data2_EX <= '0;
			instruction_EX <= '0;
			imm_EX <= '0;
      branch_target_adder_EX <= '0;
		end else begin
      pc_EX <= pc_ID;
      pc_plus4_EX <= pc_plus4_ID;
			alu_op_EX <= alu_op_ID;
			ALUSrc1_EX <= ALUSrc1_ID;
			ALUSrc2_EX <= ALUSrc2_ID;
			RegWrite_EX <= RegWrite_ID;
			Branch_EX <= Branch_ID;
			Jump_EX <= Jump_ID;
			MemWrite_EX <= MemWrite_ID;
			MemRead_EX <= MemRead_ID;
			WBSel_EX <= WBSel_ID;
			rd_data1_EX <= rd_data1_ID;
			rd_data2_EX <= rd_data2_ID;
			instruction_EX <= instruction_ID;
			imm_EX <= imm_ID;
      branch_target_adder_EX <= branch_target_adder_ID;
		end
	end



endmodule
