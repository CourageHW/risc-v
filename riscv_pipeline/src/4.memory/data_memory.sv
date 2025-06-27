`timescale 1ns/1ps
import defines::*;

module data_memory (
    input  logic clk,
    input  logic rst_n,
    input  logic re,
    input  logic we,
    input  logic [2:0] funct3_i,
    input  logic [DATA_WIDTH-1:0] addr_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

    (* ram_style = "block" *) 
    logic [DATA_WIDTH-1:0] memory [0:DATA_MEM_DEPTH-1];

    logic [DATA_MEM_ADDR_WIDTH-1:0] word_addr;
    logic [3:0] byte_en;

    assign word_addr = addr_i[DATA_MEM_ADDR_WIDTH+1:2];
    
    // --- 읽기 로직 (수정) ---
    // re 신호와 상관없이 항상 메모리 값을 출력하도록 합니다.
    // 어차피 상위 모듈에서 lw 명령어일 때만 이 값을 사용(WBSel=WB_MEM)하므로 안전합니다.
    // re=0일 때 'x'를 출력하는 것이 문제의 원인이었을 수 있습니다.
    assign rd_data_o = memory[word_addr];

    // --- 쓰기 로직 (기존과 동일) ---
    always_comb begin
        byte_en = 4'b0000;
        if (we) begin
            case (funct3_i)
                FUNCT3_SB: begin
                    unique case (addr_i[1:0])
                        2'b00: byte_en = 4'b0001;
                        2'b01: byte_en = 4'b0010;
                        2'b10: byte_en = 4'b0100;
                        2'b11: byte_en = 4'b1000;
                    endcase
                end
                FUNCT3_SH: begin
                    if (addr_i[1] == 1'b0) byte_en = 4'b0011;
                    else                   byte_en = 4'b1100;
                end
                FUNCT3_SW: begin
                    byte_en = 4'b1111;
                end
                default: byte_en = 4'b0000;
            endcase
        end
    end

    // 바이트 인에이블을 이용한 실제 쓰기 (기존과 동일)
    always_ff @(posedge clk) begin
        if (byte_en[0]) memory[word_addr][7:0]   <= wr_data_i[7:0];
        if (byte_en[1]) memory[word_addr][15:8]  <= wr_data_i[15:8];
        if (byte_en[2]) memory[word_addr][23:16] <= wr_data_i[23:16];
        if (byte_en[3]) memory[word_addr][31:24] <= wr_data_i[31:24];
    end
    
    // 시뮬레이션을 위한 메모리 초기화
    initial begin
        for (int i = 0; i < DATA_MEM_DEPTH; i++) begin
            memory[i] = '0;
        end
    end

endmodule