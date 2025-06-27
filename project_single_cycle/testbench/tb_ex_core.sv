`timescale 1ns/1ps
import defines::*;

module tb_ex_core;

    // --- Signal Declarations ---
    alu_op_class_e  ALUOp_i;
    logic [2:0]     funct3_i;
    logic [6:0]     funct7_i;
    logic [DATA_WIDTH-1:0] operand1_i, operand2_i, result_o;
    logic           ZeroFlag_o;

    // --- DUT Instantiation ---
    ex_core dut (.*); // Connect by name

    // --- Helper Task for Verification ---
    task run_test(
        input alu_op_class_e alu_op_class,
        input logic [2:0]    funct3,
        input logic [6:0]    funct7,
        input logic [DATA_WIDTH-1:0] op1,
        input logic [DATA_WIDTH-1:0] op2,
        input logic [DATA_WIDTH-1:0] expected_result,
        input logic                  expected_zero,
        input string                 test_name
    );
        $display("----------------------------------------");
        $display("Running test: %s", test_name);

        // Drive inputs
        ALUOp_i = alu_op_class;
        funct3_i = funct3;
        funct7_i = funct7;
        operand1_i = op1;
        operand2_i = op2;

        #1; // Wait for combinational logic to settle

        // Check final outputs
        assert (result_o === expected_result)
            else $fatal(1, "[FAIL] %s: Result mismatch. Expected: %h, Got: %h", test_name, expected_result, result_o);
        
        assert (ZeroFlag_o === expected_zero)
            else $fatal(1, "[FAIL] %s: ZeroFlag mismatch. Expected: %b, Got: %b", test_name, expected_zero, ZeroFlag_o);

        $display("[PASS] %s", test_name);
    endtask

    // --- Main Test Sequence ---
    initial begin
        $display("INFO: Execution Core (ALU + ALU Control) Unit Test Started.");
        
        // --- R-Type ADD Test ---
        run_test(ALUOP_RTYPE, FUNCT3_ADD_SUB, FUNCT7_ADD, 32'd100, 32'd200, 32'd300, 1'b0, "R-Type: ADD");

        // --- R-Type SUB Test for Zero Flag ---
        run_test(ALUOP_RTYPE, FUNCT3_ADD_SUB, FUNCT7_SUB, 32'd50, 32'd50, 32'd0, 1'b1, "R-Type: SUB for Zero");
        
        // --- I-Type ADDI Test (ALUOp should trigger ADD) ---
        run_test(ALUOP_ITYPE_ARITH, FUNCT3_ADD_SUB, 7'bxxxxxx, 32'd1000, 32'd5, 32'd1005, 1'b0, "I-Type: ADDI");
        
        // --- Branch BEQ Test (ALUOp should trigger SUB) ---
        run_test(ALUOP_BRANCH, FUNCT3_BEQ, 7'bxxxxxx, 32'd77, 32'd77, 32'd0, 1'b1, "Branch: BEQ (Equal)");

        // --- LUI Test (ALUOp should trigger PASS_B) ---
        run_test(ALUOP_LUI, 3'bxxx, 7'bxxxxxx, 32'd0, 32'hABCDE, 32'hABCDE, 1'b0, "LUI: Pass-B");
        
        $display("----------------------------------------");
        $display("\n===============================================");
        $display("  [SUCCESS] All Execution Core tests passed!");
        $display("===============================================");
        $finish;
    end

endmodule