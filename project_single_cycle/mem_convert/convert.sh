#!/bin/bash

# 1. 어셈블 및 링크 (동일)
riscv64-unknown-elf-as -o test_program.o test_program3.s
riscv64-unknown-elf-ld -Ttext=0x0 -o test_program.elf test_program.o

# 2. ELF 파일에서 순수 머신 코드 바이너리(.bin) 추출 (가장 중요한 변경점)
# objdump 대신 objcopy를 사용하여 raw binary를 생성합니다.
riscv64-unknown-elf-objcopy -O binary test_program.elf program.bin

# 3. 바이너리 파일을 Verilog 메모리 파일(.mem)로 변환
python3 bin_to_mem.py

# 4. 중간 파일 정리
rm -rf *.elf *.o *.bin

echo "변환 완료: program.mem 파일이 생성되었습니다."