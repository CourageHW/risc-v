package defines;
    // 1. parameter
    parameter DATA_WIDTH    = 32;

    // Register File
    parameter REG_COUNT     = 32;
    parameter ADDR_WIDTH    = $clog2(REG_COUNT);

    // Instruction Memory
    parameter INST_MEM_DEPTH = 1024;
    parameter INST_MEM_ADDR_WIDTH = $clog2(INST_MEM_DEPTH);

    // Data Memory
    parameter DATA_MEM_DEPTH = 1024;
    parameter DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);

    // Main Opcodes
    parameter OPCODE_LOAD    = 7'b0000011;  // I-type: lb, lh, lw, ld, lbu, lhu, lwu
    parameter OPCODE_ITYPE   = 7'b0010011;  // I-type: addi, slti, sltiu, xori, ori, andi, slli, srli, srai
    parameter OPCODE_AUIPC   = 7'b0010111;  // U-type: auipc
    parameter OPCODE_STORE   = 7'b0100011;  // S-type: sb, sh, sw, sd
    parameter OPCODE_RTYPE   = 7'b0110011;  // R-type: add, sub, sll, slt, sltu, xor, srl, sra, or, and
    parameter OPCODE_LUI     = 7'b0110111;  // U-type: lui
    parameter OPCODE_BRANCH  = 7'b1100011;  // SB-type: beq, bne, blt, bge, bltu, bgeu
    parameter OPCODE_JALR    = 7'b1100111;  // I-type: jalr
    parameter OPCODE_JAL     = 7'b1101111;  // UJ-type: jal
    
    // For R-type
    parameter FUNCT7_ADD     = 7'b0000000;
    parameter FUNCT7_SUB     = 7'b0100000;
    parameter FUNCT7_SRL     = 7'b0000000;
    parameter FUNCT7_SRA     = 7'b0100000;
    
    // For I-type shift
    parameter FUNCT7_SRLI    = 7'b0000000;
    parameter FUNCT7_SRAI    = 7'b0100000;

    // For R-type and I-type Arithmetic
    parameter FUNCT3_ADD_SUB = 3'b000;
    parameter FUNCT3_SLL     = 3'b001;
    parameter FUNCT3_SLT     = 3'b010;
    parameter FUNCT3_SLTU    = 3'b011;
    parameter FUNCT3_XOR     = 3'b100;
    parameter FUNCT3_SRL_SRA = 3'b101;
    parameter FUNCT3_OR      = 3'b110;
    parameter FUNCT3_AND     = 3'b111;

    // For Load/Store
    parameter FUNCT3_SB      = 3'b000;
    parameter FUNCT3_SH      = 3'b001;
    parameter FUNCT3_SW      = 3'b010;
    parameter FUNCT3_LB      = 3'b000;
    parameter FUNCT3_LH      = 3'b001;
    parameter FUNCT3_LW      = 3'b010;
    parameter FUNCT3_LBU     = 3'b100;
    parameter FUNCT3_LHU     = 3'b101;
    parameter FUNCT3_LWU     = 3'b110;


    // For Branch
    parameter FUNCT3_BEQ     = 3'b000;
    parameter FUNCT3_BNE     = 3'b001;
    parameter FUNCT3_BLT     = 3'b100;
    parameter FUNCT3_BGE     = 3'b101;
    parameter FUNCT3_BLTU    = 3'b110;
    parameter FUNCT3_BGEU    = 3'b111;

    // Main Control -> ALU Control 에게 보내는 'ALU 행동 클래스'
    typedef enum logic [2:0] {
        ALUOP_MEM_ADDR,    // Load/Store: 무조건 ADD (주소계산)
        ALUOP_BRANCH,      // Branch: 무조건 SUB (두 값 비교)
        ALUOP_LUI,         // LUI: ALU는 입력 B를 그대로 통과 (PASS_B)
        ALUOP_JUMP,         // JAL, AUIPC: 무조건 ADD (PC 기반 주소계산)
        ALUOP_RTYPE,       // R-type: funct3, funct7 모두 봐야 함 (add, sub, xor...)
        ALUOP_ITYPE_ARITH, // I-type 산술/논리: funct3만 보면 됨 (addi, xori...)
        ALUOP_NONE         // 사용 안함 또는 에러
    } alu_op_class_e;

    // ALU Control -> ALU 에게 보내는 '최종 작전 명령'
    typedef enum logic [3:0] {
        ALU_ADD,       // 덧셈
        ALU_SUB,       // 뺄셈
        ALU_AND,       // &
        ALU_OR,        // |
        ALU_XOR,       // ^
        ALU_SLL,       // <<
        ALU_SRL,       // >>
        ALU_SRA,       // >>>
        ALU_SLT,       // signed 비교 (<)
        ALU_SLTU,      // unsigned 비교 (<)
        ALU_PASS_B,    // = operand2
        ALU_X          // NONE
    } alu_control_e;    

    // ImmSel
    typedef enum logic [2:0] {
        IMM_TYPE_R,
        IMM_TYPE_I, 
        IMM_TYPE_S, 
        IMM_TYPE_B, 
        IMM_TYPE_U, 
        IMM_TYPE_J,
        IMM_NONE
    } imm_sel_e;
endpackage