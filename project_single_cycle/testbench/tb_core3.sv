`timescale 1ns/1ps
import defines::*;

module tb_core_stress;

    localparam CLK_PERIOD = 10;
    logic clk, rst_n;

    core dut ( .clk(clk), .rst_n(rst_n) );

    initial begin clk = 0; forever #(CLK_PERIOD/2) clk = ~clk; end
    initial begin
        $dumpfile("core_stress.vcd");
        $dumpvars(0, dut);
    end

    initial begin
        $display("[%0t] INFO: Core Stress Test Started.", $time);
        
        // --- Reset ---
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        // --- Run Program ---
        // The program has 22 instructions. Give it enough cycles.
        $display("[%0t] INFO: Running stress test program...", $time);
        repeat(25) @(posedge clk);
        #1;

        // --- Final Verification ---
        $display("[%0t] INFO: Verifying final state...", $time);
        
        // Check key register values
        assert(dut.reg_file_inst.registers[0]  === 32'd0)        else $fatal(1, "[FAIL] x0 is not zero!");
        assert(dut.reg_file_inst.registers[8]  === 32'd1)        else $fatal(1, "[FAIL] s0(x8) mismatch!");
        assert(dut.reg_file_inst.registers[19] === 32'hF8000000) else $fatal(1, "[FAIL] s3(x19) mismatch!");
        assert(dut.reg_file_inst.registers[21] === 32'hFFFFFFFB) else $fatal(1, "[FAIL] s5(x21) mismatch!");
        assert(dut.reg_file_inst.registers[23] === 32'h00020000) else $fatal(1, "[FAIL] s7(x23) mismatch!");
        assert(dut.reg_file_inst.registers[5]  === 32'd1)        else $fatal(1, "[FAIL] t0(x5) mismatch!");
        assert(dut.reg_file_inst.registers[6]  === 32'd0)        else $fatal(1, "[FAIL] t1(x6) mismatch!");
        assert(dut.reg_file_inst.registers[7]  === 32'hFFFFFFFE) else $fatal(1, "[FAIL] t2(x7) mismatch!");
        assert(dut.reg_file_inst.registers[28] === 32'h0000FFFB) else $fatal(1, "[FAIL] t3(x28) mismatch!");
        assert(dut.reg_file_inst.registers[29] === 32'h00000001) else $fatal(1, "[FAIL] t4(x29) mismatch!");

        // Check key memory values
        assert(dut.data_mem_inst.memory[125] === 32'hFFFFFFFE) else $fatal(1, "[FAIL] Memory @500 mismatch!"); // 500/4 = 125
        assert(dut.data_mem_inst.memory[124] === 32'h0100FFFB) else $fatal(1, "[FAIL] Memory @496/495 mismatch!"); // 496/4 = 124

        $display("\n==============================================");
        $display("  [SUCCESS] Your CPU survived the stress test!");
        $display("==============================================");
        
        $finish;
    end

endmodule