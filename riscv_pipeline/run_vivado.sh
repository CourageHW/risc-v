#!/bin/zsh
clear

echo "============================================"
echo "| Starting Vivado Simulation in Batch Mode |"
echo "============================================"

vivado -mode batch -nojournal -nolog -source simulate.tcl

echo "\n=========================================="
echo "|       Vivado Simulation Finished       |"
echo "=========================================="
