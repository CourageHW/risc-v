`timescale 1ns/1ps
import defines::*;

module tb_pipeline_stress;
    
    localparam CLK_PERIOD = 10;
    
    logic clk;
    logic rst_n;

    riscv_pipeline_core dut ( 
      .clk(clk), 
      .rst_n(rst_n)
    );

    initial begin 
      clk=0; 
      forever #(CLK_PERIOD/2) clk=~clk; 
    end

    initial begin
        $display("[INFO] Pipeline Stress Test (Hazard-Free) Started.");
        
        // --- 1. Reset ---
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        // --- 2. Run program ---
        $display("[INFO] Running stress test program...");
        repeat(25) @(posedge clk);
        #1;

        // --- 3. Final Verification ---
        $display("[INFO] Verifying final register and memory state...");
        
        // Check Register Values
        assert(dut.reg_file_inst.registers[10] === 100)  else $fatal(1, "[FAIL] x10 should be 100!");
        assert(dut.reg_file_inst.registers[11] === 20)   else $fatal(1, "[FAIL] x11 should be 20!");
        assert(dut.reg_file_inst.registers[12] === 120)  else $fatal(1, "[FAIL] x12 (add) should be 120!");
        assert(dut.reg_file_inst.registers[13] === 80)   else $fatal(1, "[FAIL] x13 (sub) should be 80!");
        assert(dut.reg_file_inst.registers[14] === 120)  else $fatal(1, "[FAIL] x14 (lw) should be 120!");
        assert(dut.reg_file_inst.registers[15] === 80)   else $fatal(1, "[FAIL] x15 (lw) should be 80!");
        assert(dut.reg_file_inst.registers[16] === 1)    else $fatal(1, "[FAIL] x16 (branch) should be 1!");
        $display("[SUCCESS] Check Register Values");

        // Check Memory Values
        assert(dut.data_mem_inst.memory[1] === 120) // addr=4 -> index=1
            else $fatal(1, "[FAIL] Memory[4] should contain 120!");
        assert(dut.data_mem_inst.memory[2] === 80)  // addr=8 -> index=2
            else $fatal(1, "[FAIL] Memory[8] should contain 80!");
        $display("[SUCCESS] Check Memory Values");

        $display("\n=======================================================================");
        $display("  [SUCCESS] Your Baseline Pipeline passed the COMPLEX NO-HAZARD test!");
        $display("=======================================================================");

        #1000;
        $finish;
    end

endmodule
