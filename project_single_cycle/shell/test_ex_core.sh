#!/bin/zsh
clear

echo "Compiling sources..."
iverilog -o sim.out -g2012 ./src/header/*.sv ./src/execute/*.sv ./testbench/tb_ex_core.sv && \

echo "Running simulation..."
time vvp sim.out || exit 1

echo "Simulation finished."
rm -rf sim.out

#vcd2fst dump.vcd dump.fst
#gtkwave dump.fst
#rm -rf dump.vcd dump.fst