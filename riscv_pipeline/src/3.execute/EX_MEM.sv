`timescale 1ns/1ps
import defines::*;

module EX_MEM (
    input  logic                  clk,
    input  logic                  rst_n,

    // --- Inputs from Execute Stage ---
    // Control Signals
    input  logic                  RegWrite_EX, 
    input  logic                  MemWrite_EX,
    input  logic                  MemRead_EX,
    input  wb_sel_e               WBSel_EX,   
    input  logic                  Branch_EX,
    input  logic                  Jump_EX,

    // Data Signals
    input  logic                  zero_flag_EX,
    input  logic [DATA_WIDTH-1:0] alu_result_EX, 
    input  logic [DATA_WIDTH-1:0] rd_data2_EX,    
    input  logic [DATA_WIDTH-1:0] pc_plus4_EX,   
    input  logic [DATA_WIDTH-1:0] instruction_EX,
    input  logic [DATA_WIDTH-1:0] branch_target_adder_EX,

    // --- Outputs to Memory Stage ---
    // Control Signals
    output logic                  RegWrite_MEM,
    output logic                  MemWrite_MEM,
    output logic                  MemRead_MEM,
    output wb_sel_e               WBSel_MEM,
    output logic                  Branch_MEM,
    output logic                  Jump_MEM,

    // Data Signals
    output logic                  zero_flag_MEM,
    output logic [DATA_WIDTH-1:0] alu_result_MEM,
    output logic [DATA_WIDTH-1:0] rd_data2_MEM,
    output logic [DATA_WIDTH-1:0] pc_plus4_MEM,
    output logic [DATA_WIDTH-1:0] instruction_MEM,
    output logic [DATA_WIDTH-1:0] branch_target_adder_MEM
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWrite_MEM   <= 1'b0;
            MemWrite_MEM   <= 1'b0;
            MemRead_MEM    <= 1'b0;
            WBSel_MEM      <= WB_NONE; 
            Branch_MEM     <= 1'b0;
            Jump_MEM       <= 1'b0;
            zero_flag_MEM  <= 1'b0;
            alu_result_MEM <= '0;
            rd_data2_MEM   <= '0;
            pc_plus4_MEM   <= '0;
            instruction_MEM<= '0;
            branch_target_adder_MEM <= '0;
        end else begin
            RegWrite_MEM   <= RegWrite_EX;
            MemWrite_MEM   <= MemWrite_EX;
            MemRead_MEM    <= MemRead_EX;
            WBSel_MEM      <= WBSel_EX;
            Branch_MEM     <= Branch_EX;
            Jump_MEM       <= Jump_EX;
            zero_flag_MEM  <= zero_flag_EX;
            alu_result_MEM <= alu_result_EX;
            rd_data2_MEM   <= rd_data2_EX;
            pc_plus4_MEM   <= pc_plus4_EX;
            instruction_MEM<= instruction_EX;
            branch_target_adder_MEM <= branch_target_adder_EX;
        end
    end

endmodule
