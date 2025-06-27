`timescale 1ns/1ps
import defines::*;

// EX/MEM 파이프라인 레지스터
// 역할: Execute 스테이지의 모든 결과(ALU 결과, 제어 신호 등)를
// 한 클럭 사이클 동안 안전하게 저장했다가, Memory 스테이지로 전달합니다.
module EX_MEM (
    input  logic                  clk,
    input  logic                  rst_n,

    // --- Inputs from Execute Stage ---
    // Control Signals
    input  logic                  RegWrite_EX, // 오타 수정: RegWrtie -> RegWrite
    input  logic                  MemWrite_EX,
    input  logic                  MemRead_EX,
    input  wb_sel_e               WBSel_EX,    // wb_sel_e 타입 사용
    input  logic                  Branch_EX,
    input  logic                  Jump_EX,

    // Data Signals
    input  logic                  zero_flag_EX,
    input  logic [DATA_WIDTH-1:0] alu_result_EX, // 오타 수정: 1비트 -> 32비트
    input  logic [DATA_WIDTH-1:0] rd_data2_EX,   // sw 명령어를 위해 전달되어야 할 데이터
    input  logic [DATA_WIDTH-1:0] pc_plus4_EX,   // jal, jalr을 위해 전달되어야 할 PC+4
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
            // 리셋 시, 모든 제어 신호는 비활성화(0)하고, 데이터는 0으로 초기화합니다.
            // 이는 파이프라인 버블(bubble)을 만드는 가장 안전한 방법입니다.
            RegWrite_MEM   <= 1'b0;
            MemWrite_MEM   <= 1'b0;
            MemRead_MEM    <= 1'b0;
            WBSel_MEM      <= WB_NONE; // 또는 '0
            Branch_MEM     <= 1'b0;
            Jump_MEM       <= 1'b0;
            zero_flag_MEM  <= 1'b0;
            alu_result_MEM <= '0;
            rd_data2_MEM   <= '0;
            pc_plus4_MEM   <= '0;
            instruction_MEM<= '0;
            branch_target_adder_MEM <= '0;
        end else begin
            // 클럭 엣지에서, 모든 입력 신호를 그대로 출력 레지스터로 전달합니다.
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
