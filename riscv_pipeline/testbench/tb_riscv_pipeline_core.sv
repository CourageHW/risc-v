`timescale 1ns/1ps
import defines::*;

module tb_riscv_pipeline_core;

    localparam CLK_PERIOD = 10;
    logic clk, rst_n;

    // The core is now autonomous.
    riscv_pipeline_core dut ( .clk(clk), .rst_n(rst_n) );

    initial begin clk = 0; forever #(CLK_PERIOD/2) clk = ~clk; end

    initial begin
        $display("INFO: Forwarding-only Test Started (No Stall Needed)");

        // --- 1. Reset ---
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        // --- 2. Run program ---
        $display("INFO: Running forwarding-only program...");
        repeat(15) @(posedge clk); // 충분한 시간 제공
        #1;

        // --- 3. Final Verification ---
        $display("INFO: Verifying final register states...");

        assert(dut.reg_file_inst.registers[1] == 10)
            else $fatal(1, "[FAIL] x1 should be 10");
        assert(dut.reg_file_inst.registers[2] == 20)
            else $fatal(1, "[FAIL] x2 should be 20");
        assert(dut.reg_file_inst.registers[3] == 30)
            else $fatal(1, "[FAIL] x3 = x1 + x2 = 30");
        assert(dut.reg_file_inst.registers[4] == 40)
            else $fatal(1, "[FAIL] x4 = x3 + x1 = 40");
        assert(dut.reg_file_inst.registers[5] == 60)
            else $fatal(1, "[FAIL] x5 = x4 + x2 = 60");
        assert(dut.reg_file_inst.registers[6] == 90)
            else $fatal(1, "[FAIL] x6 = x5 + x3 = 90");
        assert(dut.reg_file_inst.registers[7] == 100)
            else $fatal(1, "[FAIL] x7 = x6 + x1 = 100");

        $display("\n=========================================================");
        $display("  [SUCCESS] Forwarding-Only Test Passed!");
        $display("=========================================================");

        $finish;
    end

endmodule
