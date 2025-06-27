#!/bin/zsh
clear

echo "============================================"
echo "| Starting Vivado Simulation in Batch Mode |"
echo "============================================"

# Vivado를 GUI 없이(batch mode) 실행하고,
# simulate.tcl 스크립트를 소스로 하여 명령을 실행합니다.
vivado -mode batch -nojournal -nolog -source simulate.tcl

echo "\n========================================="
echo "  Vivado Simulation Finished."
echo "========================================="