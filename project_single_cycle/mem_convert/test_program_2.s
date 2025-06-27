.global _start
.section .text

_start:
    # 1. 초기화 및 레지스터 설정
    addi sp, zero, 256     # sp (x2) = 256 (메모리 상단)
    addi s0, zero, 0       # s0 (x8) = 0
    addi s1, zero, 0       # s1 (x9) = 0
    addi s2, zero, 0       # s2 (x10) = 0
    addi s3, zero, 0       # s3 (x11) = 0
    addi t0, zero, 0       # t0 (x5) = 0
    addi t1, zero, 0       # t1 (x6) = 0
    addi t2, zero, 0       # t2 (x7) = 0

    # 2. LUI/AUIPC 테스트 (U-type)
    lui t0, 0x12345        # t0 = 0x12345000 (상위 20비트 로드)
    auipc t1, 0x67890      # t1 = PC + (0x67890 << 12) (PC Relative)
                           # (PC값에 따라 달라지므로, 검증 시 주의 필요)
                           # 이 라인의 주소가 0x08이라고 가정하면, PC는 0x08
                           # t1 = 0x08 + 0x67890000 = 0x67890008

    # 3. I-Type 연산 테스트 (addi, xori, ori, andi, slli, srli, srai)
    addi s0, zero, 100     # s0 = 100
    addi s1, s0, 25        # s1 = s0 + 25 = 125
    
    xori t0, s0, 0xFF      # t0 = s0 XOR 0xFF (100 XOR 255 = 155)
    andi t1, s0, 0x0F      # t1 = s0 AND 0x0F (100 AND 15 = 4)
    ori t2, s0, 0xF0       # t2 = s0 OR 0xF0 (100 OR 240 = 244)

    addi s2, zero, -1      # s2 = -1 (0xFFFFFFFF)
    slli s2, s2, 4         # s2 = s2 << 4 (0xFFFFFFF0)
    srli s2, s2, 8         # s2 = s2 >> 8 (논리 시프트: 0x00FFFFFF)
    srai s2, s2, 4         # s2 = s2 >>> 4 (산술 시프트: 0xFFF00000)

    # 4. R-Type 연산 테스트 (add, sub, sll, srl, sra, xor, or, and, slt, sltu)
    addi t0, zero, 50      # t0 = 50
    addi t1, zero, 20      # t1 = 20

    add s3, t0, t1         # s3 = t0 + t1 = 50 + 20 = 70
    sub s0, t0, t1         # s0 = t0 - t1 = 50 - 20 = 30

    sll t2, t1, t0         # t2 = t1 << t0 (20 << 50, 실제로는 20 << (50 % 32) = 20 << 18)
                           # 20 * (2^18) = 5242880
                           # (risc-v는 shift amount를 rs2[4:0]으로 제한)

    addi t0, zero, -100    # t0 = -100
    addi t1, zero, 50      # t1 = 50
    
    slt s0, t0, t1         # s0 = (t0 < t1) ? 1 : 0 (signed) (-100 < 50) ? 1 : 0 = 1
    sltu s1, t0, t1        # s1 = (t0 < t1) ? 1 : 0 (unsigned) (0xFFFFFF9C < 50) ? 1 : 0 = 0

    xor s2, t0, t1         # s2 = t0 XOR t1 (-100 XOR 50)
    or s3, t0, t1          # s3 = t0 OR t1 (-100 OR 50)
    and s0, t0, t1         # s0 = t0 AND t1 (-100 AND 50)
    
    # s2 (0xFFFFFF9C) >>> 2
    addi t0, zero, 2       # t0 = 2 (shift amount)
    sra s2, s2, t0         # s2 = s2 >>> 2 (산술 시프트)

    # 5. 메모리 로드/저장 테스트 (sb, sh, sw, lb, lh, lw, lbu, lhu, lwu)
    # 메모리 초기화
    li t0, 0x11111111      # t0 = 0x11111111 (li 사용)
    sw t0, 0(sp)           # memory[256] = 0x11111111

    li t0, 0x22222222      # t0 = 0x22222222 (li 사용)
    sw t0, -4(sp)          # memory[252] = 0x22222222

    li t0, 0x33333333      # t0 = 0x33333333 (li 사용)
    sw t0, -8(sp)          # memory[248] = 0x33333333

    # 바이트/하프워드/워드 저장
    li t0, 0xABCD          # t0 = 0x0000ABCD (li 사용)
    sh t0, -10(sp)         # memory[246] = 0xABCD (half-word)
                           # 246 (0xFB)은 워드 주소 61, offset 2 (binary 10)
                           # memory[61][31:16] = 0xABCD

    addi t0, zero, 0xEF    # t0 = 0xEF (8비트 값 - 12비트 범위 내이므로 addi 사용 가능)
    sb t0, -11(sp)         # memory[245] = 0xEF (byte)
                           # 245 (0xF5)은 워드 주소 61, offset 1 (binary 01)
                           # memory[61][15:8] = 0xEF
    
    # 로드 전 레지스터 클리어 (정확한 로드 값 확인용)
    addi t0, zero, 0
    addi t1, zero, 0
    addi t2, zero, 0
    addi s0, zero, 0
    addi s1, zero, 0
    addi s2, zero, 0

    # 바이트/하프워드/워드 로드 (signed/unsigned)
    lw t0, 0(sp)           # t0 = memory[256] (0x11111111)
    lhu t1, -10(sp)        # t1 = memory[246] (0xABCD) (unsigned)
    lbu t2, -11(sp)        # t2 = memory[245] (0xEF) (unsigned)
    
    # signed 로드 예시 (s0는 음수값이 나오도록)
    addi t0, zero, 0x80    # t0 = 0x80 (12비트 범위 내이므로 addi 사용 가능)
    sb t0, -12(sp)         # memory[244] = 0x80 (byte) -> memory[61][7:0]
    lb s0, -12(sp)         # s0 = memory[244] (0x80) (signed) -> 0xFFFFFF80

    li t0, 0x8000          # t0 = 0x8000 (li 사용)
    sh t0, -14(sp)         # memory[242] = 0x8000 (half-word) -> memory[60][31:16] (addr[1] == 1)
    lh s1, -14(sp)         # s1 = memory[242] (0x8000) (signed) -> 0xFFFF8000

    # 프로그램 종료 (무한 루프)
end_of_test:
    j end_of_test