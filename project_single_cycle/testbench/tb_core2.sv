`timescale 1ns/1ps

module tb_core;

    localparam CLK_PERIOD = 10;
    localparam DATA_MEM_DEPTH = 1024; 

    logic clk, rst_n;

    core dut ( .clk(clk), .rst_n(rst_n) );


    // data memory 초기화
    initial begin
        for (int i = 0; i < DATA_MEM_DEPTH; i++) begin
            dut.data_mem_inst.memory[i] = '0; 
        end
    end

    initial begin clk = 0; forever #(CLK_PERIOD/2) clk = ~clk; end
    initial begin
        $dumpfile("final_core.vcd");
        $dumpvars(0, dut);
    end

    initial begin
        $display("[%0tns] INFO: Single-Cycle Core Verification Started.", $time);
        
        rst_n = 1'b0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1'b1;

        $display("[%0tns] INFO: Reset released. Running the correct program (66 instructions)...", $time);
        
        // 'li' 확장으로 총 66개의 명령어가 실행됩니다.
        repeat(66) @(posedge clk); 
        
        #1; 

        $display("[%0tns] INFO: Program finished. Verifying final state...", $time);
        
        // --- 레지스터 최종 상태 검증 (수정된 예상 값) ---
        
        assert(dut.reg_file_inst.registers[2] === 32'h00000100) 
            else $fatal(1, "[FAIL] sp(x2) mismatch! Expected 0x00000100, got %h", dut.reg_file_inst.registers[2]);

        // =====================================================================
        // ===                      가장 중요한 수정점                       ===
        // =====================================================================
        // t0(x5)는 lw 이후 addi, li 명령어에 의해 값이 덮어쓰기 됩니다.
        // 마지막으로 t0에 값을 쓰는 명령어는 'li t0, 0x8000' 입니다.
        assert(dut.reg_file_inst.registers[5] === 32'h00008000) 
            else $fatal(1, "[FAIL] t0(x5) mismatch! Expected 0x00008000, got %h", dut.reg_file_inst.registers[5]);
        
        assert(dut.reg_file_inst.registers[6] === 32'h0000ABCD) 
            else $fatal(1, "[FAIL] t1(x6) mismatch! Expected 0x0000ABCD, got %h", dut.reg_file_inst.registers[6]);
        
        assert(dut.reg_file_inst.registers[7] === 32'h000000EF) 
            else $fatal(1, "[FAIL] t2(x7) mismatch! Expected 0x000000EF, got %h", dut.reg_file_inst.registers[7]);

        assert(dut.reg_file_inst.registers[8] === 32'hFFFFFF80) 
            else $fatal(1, "[FAIL] s0(x8) mismatch! Expected 0xFFFFFF80, got %h", dut.reg_file_inst.registers[8]);
        
        assert(dut.reg_file_inst.registers[9] === 32'hFFFF8000) 
            else $fatal(1, "[FAIL] s1(x9) mismatch! Expected 0xFFFF8000, got %h", dut.reg_file_inst.registers[9]);
        
        assert(dut.reg_file_inst.registers[10] === 32'hFFFFFFFFEB) 
            else $fatal(1, "[FAIL] s2(x10) mismatch! Expected 0xFFFFFFEB, got %h", dut.reg_file_inst.registers[10]);
        
        assert(dut.reg_file_inst.registers[11] === 32'hFFFFFFBE) 
            else $fatal(1, "[FAIL] s3(x11) mismatch! Expected 0xFFFFFFBE, got %h", dut.reg_file_inst.registers[11]);

        // --- 메모리 최종 상태 검증 (이전과 동일) ---
        assert(dut.data_mem_inst.memory[64] === 32'h11111111) 
            else $fatal(1, "[FAIL] Memory @256 (word 64) mismatch! Expected 0x11111111, got %h", dut.data_mem_inst.memory[64]);
        assert(dut.data_mem_inst.memory[63] === 32'h22222222) 
            else $fatal(1, "[FAIL] Memory @252 (word 63) mismatch! Expected 0x22222222, got %h", dut.data_mem_inst.memory[63]);
        assert(dut.data_mem_inst.memory[62] === 32'h33333333) 
            else $fatal(1, "[FAIL] Memory @248 (word 62) mismatch! Expected 0x33333333, got %h", dut.data_mem_inst.memory[62]);
        assert(dut.data_mem_inst.memory[61] === 32'hABCDEF80) 
            else $fatal(1, "[FAIL] Memory @244 (word 61) mismatch! Expected 0xABCDEF80, got %h", dut.data_mem_inst.memory[61]);
        assert(dut.data_mem_inst.memory[60] === 32'h80000000) 
            else $fatal(1, "[FAIL] Memory @240 (word 60) mismatch! Expected 0x80000000, got %h", dut.data_mem_inst.memory[60]);

        $display("\n=========================================================================");
        $display("  [SUCCESS] CONGRATULATIONS! All register and memory checks passed!");
        $display("=========================================================================");
        
        $finish;
    end

endmodule