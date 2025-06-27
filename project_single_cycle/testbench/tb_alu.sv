import defines::*;

module tb_alu;

    alu_control_e ALUControl_i;
    logic [DATA_WIDTH-1:0] operand1_i;
    logic [DATA_WIDTH-1:0] operand2_i;
    logic [DATA_WIDTH-1:0] result_o;
    logic ZeroFlag_o;

    alu alu_inst (
        .ALUControl_i   (ALUControl_i),
        .operand1_i     (operand1_i),
        .operand2_i     (operand2_i),
        .result_o       (result_o),
        .ZeroFlag_o     (ZeroFlag_o)
    );

    //initial begin
    //    $dumpfile("dump.vcd");
    //    $dumpvars(0, tb_alu);
    //end

    // --- Helper Task for running a single test case ---
    task run_test(
        input alu_control_e op_i,
        input logic [DATA_WIDTH-1:0] op1_i,
        input logic [DATA_WIDTH-1:0] op2_i,
        input logic [DATA_WIDTH-1:0] expected_result_i,
        input logic expected_zero_i,
        input string test_name
    );
        $display("----------------------------------------");
        $display("Running test: %s", test_name);
        #1;

        // Drive inputs
        ALUControl_i = op_i;
        operand1_i = op1_i;
        operand2_i = op2_i;
        
        #1; // Wait for combinational logic to settle

        // Check outputs using assertions
        assert (result_o === expected_result_i) 
            else $fatal(1, "[FAIL] %s: Result mismatch. Expected: %h, Got: %h", test_name, expected_result_i, result_o);
        
        assert (ZeroFlag_o === expected_zero_i) 
            else $fatal(1, "[FAIL] %s: ZeroFlag mismatch. Expected: %b, Got: %b", test_name, expected_zero_i, ZeroFlag_o);
            
        $display("[PASS] %s", test_name);
    endtask


    // --- Main Test Sequence ---
    initial begin
        $display("INFO: ALU Unit Test Started.");
        
        //         OP,         OP1,          OP2,     EXP_RESULT,   EXP_ZERO,     TEST_NAME
        run_test(ALU_ADD,     32'd10,       32'd20,     32'd30,       1'b0,     "ADD Positive");
        run_test(ALU_SUB,     32'd50,       32'd50,     32'd0,        1'b1,     "SUB Zero Flag Test");
        run_test(ALU_AND,     32'hFF,       32'h0F,     32'h0F,       1'b0,     "AND Test");
        run_test(ALU_OR,      32'hF0,       32'h0F,     32'hFF,       1'b0,     "OR Test");
        run_test(ALU_XOR,     32'hA5,       32'h5A,     32'hFF,       1'b0,     "XOR Test");
        run_test(ALU_SLL,     32'h1,        32'd2,      32'h4,        1'b0,     "SLL Test");
        run_test(ALU_SRL,     32'hF0000000, 32'd4,      32'h0F000000, 1'b0,     "SRL Test");
        run_test(ALU_SRA,     32'hF0000000, 32'd4,      32'hFF000000, 1'b0,     "SRA Test (Sign Extension)");
        run_test(ALU_SLT,     -10,          20,         32'd1,        1'b0,     "SLT Signed Test (true)");
        run_test(ALU_SLT,     20,           -10,        32'd0,        1'b1,     "SLT Signed Test (false)");
        run_test(ALU_SLTU,    -10,          20,         32'd0,        1'b1,     "SLTU Unsigned Test (-10 is a large num)");
        run_test(ALU_PASS_B,  32'd10,       32'd20,     32'd20,       1'b0,     "PASS_B Test");
        
        $display("----------------------------------------");
        $display("\n========================================");
        $display("  [SUCCESS] All ALU tests passed! ");
        $display("========================================");
        $finish;
    end

endmodule
