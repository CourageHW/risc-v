`timescale 1ns/1ps
import defines::*;

module tb_core;

    localparam CLK_PERIOD = 10;
    logic clk, rst_n;

    core dut ( .clk(clk), .rst_n(rst_n) );

    initial begin clk = 0; forever #(CLK_PERIOD/2) clk = ~clk; end
    initial begin
        $dumpfile("final_core.vcd");
        $dumpvars(0, dut);
    end

    initial begin
        $display("[%0t] INFO: True Single-Cycle Core Verification Started.", $time);
        
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        // 비동기 메모리이므로, 모든 명령어는 1클럭에 처리됩니다.
        // 데이터 해저드는 Single-Cycle 모델에서는 발생하지 않습니다.
        // 프로그램 전체를 실행하고 마지막에 결과를 확인합니다.
        $display("[%0t] INFO: Running full program...", $time);
        repeat(13) @(posedge clk);
        #1;

        $display("[%0t] INFO: Verifying final register and memory state...", $time);
        
        // Final Register State Verification
        assert(dut.reg_file_inst.registers[8] === 32'h12345678) else $fatal(1, "[FAIL] s0(x8) mismatch! %h", dut.reg_file_inst.registers[8]);
        assert(dut.reg_file_inst.registers[9] === 32'h0000FFFF) else $fatal(1, "[FAIL] s1(x9) mismatch! %h", dut.reg_file_inst.registers[9]);
        assert(dut.reg_file_inst.registers[5] === 32'h00000078) else $fatal(1, "[FAIL] t0(x5) mismatch! %h", dut.reg_file_inst.registers[5]); // lb는 부호 확장을 합니다.
        
        // Final Memory State Verification
        assert(dut.data_mem_inst.memory[63] === 32'h12345678) else $fatal(1, "[FAIL] Memory @252 mismatch!");
        assert(dut.data_mem_inst.memory[62] === 32'hxxxxFFFF) else $fatal(1, "[FAIL] Memory @248 mismatch!");
        assert(dut.data_mem_inst.memory[61] === 32'h78xxxxxx) else $fatal(1, "[FAIL] Memory @247 mismatch!");

        $display("\n=========================================================================");
        $display("  [SUCCESS] CONGRATULATIONS! Your Single-Cycle CPU is FULLY FUNCTIONAL!");
        $display("=========================================================================");
        
        $finish;
    end

endmodule