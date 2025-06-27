# bin_to_mem.py

import struct

input_bin_file = "program.bin"
output_mem_file = "program.mem"

try:
    with open(input_bin_file, 'rb') as f_in, open(output_mem_file, 'w') as f_out:
        while True:
            # 4바이트(32비트 명령어)씩 읽기
            word_bytes = f_in.read(4)
            if not word_bytes:
                break
            
            # 읽은 4바이트를 little-endian unsigned integer로 변환
            # '<I'는 little-endian, unsigned int를 의미
            instruction_val = struct.unpack('<I', word_bytes)[0]
            
            # 32비트 헥사 코드(8자리, 0으로 채움)로 변환하여 파일에 쓰기
            f_out.write(f'{instruction_val:08x}\n')

    print(f"'{input_bin_file}'에서 '{output_mem_file}'로 성공적으로 변환했습니다.")

except FileNotFoundError:
    print(f"오류: 입력 파일 '{input_bin_file}'을 찾을 수 없습니다.")