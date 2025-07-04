`timescale 1ns/1ps
package defines;
    parameter DATA_WIDTH    = 32;

    parameter REG_COUNT     = 32; // Number of registers in the register file
    parameter ADDR_WIDTH    = $clog2(REG_COUNT); // Address width for register file

    parameter DATA_MEM_DEPTH = 1024; // Depth of data memory
    parameter DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH); // Address width

    parameter INST_MEM_DEPTH = 1024;
    parameter INST_MEM_ADDR_WIDTH = $clog2(INST_MEM_DEPTH);


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

    // For R-type / I-type Arithmetic
    parameter FUNCT7_ADD     = 1'b0;
    parameter FUNCT7_SUB     = 1'b1;
    parameter FUNCT7_SRL     = 1'b0;
    parameter FUNCT7_SRA     = 1'b1;
    parameter FUNCT7_SRLI    = 1'b0;
    parameter FUNCT7_SRAI    = 1'b1;

    // For R-type / I-type Arithmetic
    parameter FUNCT3_ADD_SUB = 3'b000;
    parameter FUNCT3_SLL     = 3'b001;
    parameter FUNCT3_SLT     = 3'b010;
    parameter FUNCT3_SLTU    = 3'b011;
    parameter FUNCT3_XOR     = 3'b100;
    parameter FUNCT3_SRL_SRA = 3'b101;

    // For Load/Store
    parameter FUNCT3_OR      = 3'b110;
    parameter FUNCT3_AND     = 3'b111;
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


    typedef enum logic [1:0] {
      FW_NONE,    // no forwarding
      FW_MEM_ALU, // forwarding Mem Stage ALU Result
      FW_WB_DATA  // forwarding WB Stage Data
    } fw_sel_e;

    // Write Back
    typedef enum logic [1:0] {
      WB_ALU,
      WB_MEM,
      WB_PC4,
      WB_NONE
    } wb_sel_e;

    // ALUOp
    typedef enum logic [2:0] {
        ALUOP_RTYPE,         // R-type instructions
        ALUOP_ITYPE_ARITH,   // I-type arithmetic instructions (e.g., addi, slti)
        ALUOP_MEM_ADDR,      // Memory address calculations (e.g., lw, sw)
        ALUOP_BRANCH,        // Branch instructions (e.g., beq, bne)
        ALUOP_LUI,           // Load Upper Immediate
        ALUOP_JUMP,          // Jump instructions (e.g., jal, jalr)
        ALUOP_NONE
    } alu_op_e;
    
    // Imm Sel
    typedef enum logic [2:0] {
      IMM_TYPE_I,
      IMM_TYPE_S,
      IMM_TYPE_B,
      IMM_TYPE_U,
      IMM_TYPE_J,
      IMM_TYPE_R
    } imm_sel_e;

    // ALUSel
    typedef enum logic [3:0] {
        ALU_ADD,    // add, addi, lw, sw, jal, jalr
        ALU_SUB,    // sub, beq, bne, blt, bge, bltu, bgeu
        ALU_AND,    // and, andi
        ALU_OR,     // or, ori
        ALU_XOR,    // xor, xori
        ALU_SLL,    // sll, slli
        ALU_SRL,    // srl, srli
        ALU_SRA,    // sra, srai
        ALU_SLT,    // slt, slti
        ALU_SLTU,   // sltu, sltiu
        ALU_PASS_B, // lui
        ALU_X       // default case, no operation
    } alu_sel_e;

endpackage
