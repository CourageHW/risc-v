.global _start
.section .text
_start:
    # 1. Initialize values
    addi sp, zero, 256     # sp (x2) = 256 (Memory top)
    
    # Correct way to load a 32-bit constant into s0
    lui  s0, 0x12345       # s0 (x8) = 0x12345000
    addi s0, s0, 0x678     # s0 (x8) = 0x12345000 + 0x678 = 0x12345678

    addi s1, zero, -1      # s1 (x9) = -1 (0xFFFFFFFF)

    # 2. Store Word (sw)
    sw s0, -4(sp)          # Store s0 into memory at address 252

    # 3. Store Half-word (sh)
    sh s1, -8(sp)          # Store 0xFFFF into memory at address 248

    # 4. Store Byte (sb)
    sb s0, -9(sp)          # Store 0x78 into memory at address 247

    # Clear registers to ensure we are loading fresh data
    addi s0, zero, 0
    addi s1, zero, 0

    # 5. Load Word (lw)
    lw s0, -4(sp)          # s0 should become 0x12345678

    # 6. Load Half-word Unsigned (lhu)
    lhu s1, -8(sp)         # s1 should become 0x0000FFFF

    # 7. Load Byte (lb)
    lb t0, -9(sp)          # t0 (x5) should become 0x00000078

end_of_test:
    j end_of_test