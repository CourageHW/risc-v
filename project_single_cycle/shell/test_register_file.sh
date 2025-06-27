#!/bin/zsh
clear

echo "Compiling sources..."
iverilog -o sim.out -g2012 ./src/header/defines.sv ./src/decode/register_file.sv ./testbench/tb_register_file.sv && \

echo "Running simulation..."
time vvp sim.out || exit 1

echo "Simulation finished."
rm -rf sim.out

#vcd2fst dump.vcd dump.fst
#gtkwave dump.fst
#rm -rf dump.vcd dump.fst