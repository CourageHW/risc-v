`timescale 1ns/1ps
import defines::*;

// 오타를 수정한 모듈 이름으로 테스트벤치를 작성합니다.
// 당신의 파일 이름도 immediate_generator.sv로 수정해야 합니다.
module tb_immediate_generator;

    // --- Signal Declarations ---
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] imm_i_out, imm_s_out, imm_b_out, imm_u_out, imm_j_out;

    logic [6:0] opcode;
    logic test_passed;

    // --- DUT Instantiation ---
    immediate_generator dut (
        .instruction_i(instruction),
        .imm_i_out(imm_i_out),
        .imm_s_out(imm_s_out),
        .imm_b_out(imm_b_out),
        .imm_u_out(imm_u_out),
        .imm_j_out(imm_j_out)
    );

    //initial begin
    //    $dumpfile("dump.vcd");
    //    $dumpvars(0, tb_immediate_generator);
    //end

    // --- Helper Task for running a single test case ---
    task run_test(
        input logic [DATA_WIDTH-1:0] instruction_i,
        input logic [DATA_WIDTH-1:0] expected_imm_i,
        input string                 test_name
    );
        $display("----------------------------------------");
        $display("Running test: %s", test_name);
        
        // Drive input
        instruction = instruction_i;
        
        #1; // Wait for combinational logic to settle

        // Check the specific output for this instruction type
        // The type of immediate is determined by the instruction's opcode.
        // This testbench simplifies by checking only the relevant output.
        opcode = instruction[6:0];
        test_passed = 1'b0;

        case (opcode)
            OPCODE_LOAD, OPCODE_ITYPE, OPCODE_JALR:
                if (imm_i_out === expected_imm_i) test_passed = 1'b1;
            OPCODE_STORE:
                if (imm_s_out === expected_imm_i) test_passed = 1'b1;
            OPCODE_BRANCH:
                if (imm_b_out === expected_imm_i) test_passed = 1'b1;
            OPCODE_LUI, OPCODE_AUIPC:
                if (imm_u_out === expected_imm_i) test_passed = 1'b1;
            OPCODE_JAL:
                if (imm_j_out === expected_imm_i) test_passed = 1'b1;
            default: test_passed = 1'b0;
        endcase

        assert (test_passed) 
            else $fatal(1, "[FAIL] %s: Immediate mismatch.", test_name);
            
        $display("[PASS] %s -> Correct immediate generated: %h", test_name, expected_imm_i);
    endtask

    // --- Main Test Sequence ---
    initial begin
        $display("INFO: Immediate Generator Unit Test Started.");
        
        // Test cases with pre-calculated machine code and expected immediate values.
        //           Instruction (Machine Code),       Expected Immediate (32-bit),                     Test Name
        run_test(          32'hFFF30293,                      32'hFFFFFFFF,                      "I-Type: addi x5, x6, -1");
        run_test(          32'hFE742E23,                      32'hFFFFFFFC,                      "S-Type: sw x7, -4(x8)");
        run_test(          32'hFE208CE3,                      32'hFFFFFFF8,                      "B-Type: beq x1, x2, -8");
        run_test(          32'h123452B7,                      32'h12345000,                      "U-Type: lui x5, 0x12345");
        run_test(          32'hFEDFF0EF,                      32'hFFFFFFEC,                      "J-Type: jal x1, -20");
        
        $display("----------------------------------------");
        $display("\n==============================================");
        $display("  [SUCCESS] All Immediate Generator tests passed!");
        $display("==============================================");
        $finish;
    end

endmodule
