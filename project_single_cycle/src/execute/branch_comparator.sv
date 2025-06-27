import defines::*;

module branch_comparator (
    input  logic [2:0]            funct3_i,
    input  logic                  Branch_i,
    input  logic [DATA_WIDTH-1:0] operand1_i,
    input  logic [DATA_WIDTH-1:0] operand2_i,
    output logic                  branch_taken_o
);

    logic eq, ne, lt, ge, ltu, geu;

     // 비교 연산
    assign eq  = (operand1_i == operand2_i);
    assign ne  = ~eq;
    assign lt  = ($signed(operand1_i) < $signed(operand2_i));
    assign ge  = ~lt;
    assign ltu = (operand1_i < operand2_i);
    assign geu = ~ltu;
    
    // 분기 조건에 따른 결정
    always_comb begin
        if (Branch_i) begin
            case (funct3_i)
                FUNCT3_BEQ : branch_taken_o = eq;
                FUNCT3_BNE : branch_taken_o = ne;
                FUNCT3_BLT : branch_taken_o = lt;
                FUNCT3_BGE : branch_taken_o = ge;
                FUNCT3_BLTU: branch_taken_o = ltu;
                FUNCT3_BGEU: branch_taken_o = geu;
                default    : branch_taken_o = 1'b0;
            endcase
        end else begin
            branch_taken_o = 1'b0;
        end
    end
endmodule