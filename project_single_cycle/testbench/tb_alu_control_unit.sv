`timescale 1ns/1ps
import defines::*;

module tb_alu_control_unit;

    // --- Signal Declarations ---
    alu_op_class_e  ALUOp_i;
    logic [2:0]     funct3_i;
    logic [6:0]     funct7_i;
    alu_control_e   ALUControl_o; // DUT의 출력

    // --- DUT Instantiation ---
    alu_control_unit dut (
        .ALUOp_i(ALUOp_i),
        .funct3_i(funct3_i),
        .funct7_i(funct7_i),
        .ALUControl_o(ALUControl_o)
    );

    // ==========================================================
    //          Helper Functions for Debug Messaging
    // ==========================================================
    function string alu_op_class_to_string(alu_op_class_e op_class);
        case (op_class)
            ALUOP_NONE:       return "ALUOP_NONE";
            ALUOP_RTYPE:      return "ALUOP_RTYPE";
            ALUOP_ITYPE_ARITH:return "ALUOP_ITYPE_ARITH";
            ALUOP_MEM_ADDR:   return "ALUOP_MEM_ADDR";
            ALUOP_BRANCH:     return "ALUOP_BRANCH";
            ALUOP_LUI:        return "ALUOP_LUI";
            ALUOP_JUMP:       return "ALUOP_JUMP";
            default:          return "UNKNOWN_OP_CLASS";
        endcase
    endfunction

    function string alu_control_to_string(alu_control_e func);
        case (func)
            ALU_ADD:    return "ALU_ADD";
            ALU_SUB:    return "ALU_SUB";
            ALU_SLL:    return "ALU_SLL";
            ALU_SLT:    return "ALU_SLT";
            ALU_SLTU:   return "ALU_SLTU";
            ALU_XOR:    return "ALU_XOR";
            ALU_SRL:    return "ALU_SRL";
            ALU_SRA:    return "ALU_SRA";
            ALU_OR:     return "ALU_OR";
            ALU_AND:    return "ALU_AND";
            ALU_PASS_B: return "ALU_PASS_B";
            ALU_X:      return "ALU_X";
            default:    return "UNKNOWN_ALU_FUNC";
        endcase
    endfunction

    // --- Helper Task for running a single test case ---
    task run_test(
        input alu_op_class_e alu_op_class,
        input logic [2:0]    funct3,
        input logic [6:0]    funct7,
        input alu_control_e  expected_func,
        input string         test_name
    );
        $display("----------------------------------------");
        $display("Running test: %s", test_name);
        
        ALUOp_i  = alu_op_class;
        funct3_i = funct3;
        funct7_i = funct7;
        
        #1;

        // .name() 대신 우리가 만든 helper function을 사용합니다.
        assert (ALUControl_o === expected_func) 
            else $fatal(1, "[FAIL] %s: ALUFunc mismatch. Expected: %s, Got: %s", 
                           test_name, alu_control_to_string(expected_func), alu_control_to_string(ALUControl_o));
            
        $display("[PASS] %s -> %s", test_name, alu_control_to_string(expected_func));
    endtask

    // --- Main Test Sequence ---
    initial begin
        $display("INFO: ALU Control Unit Test Started.");
        
        // parameter를 사용하므로 `define 매크로(백틱)를 사용하지 않습니다.
        run_test(ALUOP_MEM_ADDR,    FUNCT3_SW,          FUNCT7_ADD,          ALU_ADD,    "LW/SW Address Calc");
        run_test(ALUOP_BRANCH,      FUNCT3_BEQ,         FUNCT7_ADD,          ALU_SUB,    "Branch Compare");
        run_test(ALUOP_LUI,         3'bxxx,             7'bxxxxxx,           ALU_PASS_B, "LUI Pass-through");
        run_test(ALUOP_JUMP,        3'bxxx,             7'bxxxxxx,           ALU_ADD,    "JAL/AUIPC Address Calc");

        $display("\n--- Testing R-Type Instructions ---");
        run_test(ALUOP_RTYPE,       FUNCT3_ADD_SUB,    FUNCT7_ADD,           ALU_ADD,    "R-Type: ADD");
        run_test(ALUOP_RTYPE,       FUNCT3_ADD_SUB,    FUNCT7_SUB,           ALU_SUB,    "R-Type: SUB");
        run_test(ALUOP_RTYPE,       FUNCT3_XOR,        FUNCT7_ADD,           ALU_XOR,    "R-Type: XOR");
        run_test(ALUOP_RTYPE,       FUNCT3_SRL_SRA,    FUNCT7_SRA,           ALU_SRA,    "R-Type: SRA");

        $display("\n--- Testing I-Type Instructions ---");
        run_test(ALUOP_ITYPE_ARITH, FUNCT3_ADD_SUB,    7'bxxxxxx,            ALU_ADD,    "I-Type: ADDI");
        run_test(ALUOP_ITYPE_ARITH, FUNCT3_SLT,        7'bxxxxxx,            ALU_SLT,    "I-Type: SLTI");
        run_test(ALUOP_ITYPE_ARITH, FUNCT3_SRL_SRA,    FUNCT7_SRAI,          ALU_SRA,    "I-Type: SRAI");
        
        $display("----------------------------------------");
        $display("\n==============================================");
        $display("  [SUCCESS] All ALU Control Unit tests passed!");
        $display("==============================================");
        $finish;
    end

endmodule
