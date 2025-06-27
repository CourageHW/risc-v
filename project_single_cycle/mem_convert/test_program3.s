.global _start
.section .text
_start:
    # --- SETUP ---
    # Load initial values
    lui   s0, 0x80000      # s0(x8) = 0x80000000 (a negative number)
    addi  s0, s0, -1       # s0(x8) = 0x7FFFFFFF (largest positive number)
    addi  s1, zero, -10    # s1(x9) = -10 (0xFFFFFFF6)
    addi  sp, zero, 512    # sp(x2) = 512

    # --- ARITHMETIC & LOGIC ---
    add   s2, s0, s1       # s2(x18) = 0x7FFFFFFF + (-10) = 0x7FFFFFF5
    sub   s3, s1, s0       # s3(x19) = -10 - 0x7FFFFFFF = 0x8000000B
    xor   s4, s2, s3       # s4(x20) = 0x7FFFFFF5 ^ 0x8000000B = 0xFFFFFFFE
    or    s5, s2, s3       # s5(x21) = 0x7FFFFFF5 | 0x8000000B = 0xFFFFFFFB
    and   s6, s2, s3       # s6(x22) = 0x7FFFFFF5 & 0x8000000B = 0x00000001
    sll   s7, s6, 30       # s7(x23) = 1 << 30 = 0x40000000
    srl   s7, s7, 15       # s7(x23) = 0x40000000 >> 15 = 0x00020000
    sra   s3, s3, 4        # s3(x19) = 0x8000000B >>> 4 = 0xF8000000
    slt   t0, s1, s0       # t0(x5) = (-10 < 0x7FFFFFFF) -> 1
    sltu  t1, s3, s0       # t1(x6) = (0xF8... > 0x7F...) -> 0

    # --- MEMORY OPERATIONS ---
    sw    s4, -12(sp)      # Mem[500] = 0xFFFFFFFE
    sh    s5, -16(sp)      # Mem[496] = 0xFFFB
    sb    s6, -17(sp)      # Mem[495] = 0x01
    addi  x0, x0, 100      # Attempt to write to x0, should be ignored.

    # --- LOAD & VERIFY ---
    lw    t2, -12(sp)      # t2(x7) = 0xFFFFFFFE
    lhu   t3, -16(sp)      # t3(x28) = 0x0000FFFB (unsigned)
    lb    t4, -17(sp)      # t4(x29) = 0x00000001 (sign extended)

    # --- BRANCHING ---
    bne   t2, s4, END_FAIL # Should not branch
    addi  s0, zero, 1      # This instruction MUST execute
    beq   t4, s6, END_PASS # Should branch to END_PASS

END_FAIL:
    addi  s0, zero, 999    # If we get here, s0 becomes 999 -> TEST FAILED

END_PASS:
    j     END_PASS         # Infinite loop to end simulation