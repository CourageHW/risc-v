# ===================================================================
# Vivado Batch Simulation Script (Ultra-Robust Disk-Based Version)
# ===================================================================
# This version creates a temporary project on disk to ensure
# compatibility with all Vivado simulation commands.

# --- 1. Project Setup ---
# Define the temporary project directory and name.
set PROJ_DIR "./vivado_sim_project"
set PROJ_NAME "riscv_simulation"

puts "INFO: Creating temporary project at ${PROJ_DIR}..."
# The -force flag will overwrite the project if it already exists.
create_project ${PROJ_NAME} ${PROJ_DIR} -part xc7z020clg400-1 -force

# --- 2. Add Source Files ---
# Add all necessary source files using relative paths from the project root.
puts "INFO: Adding source files..."
add_files -fileset sim_1 [list \
    ./src/header/defines.sv \
    ./src/fetch/instruction_memory.sv\
    ./src/fetch/program_counter.sv\
    ./src/execute/alu.sv \
    ./src/execute/alu_control_unit.sv\
    ./src/execute/branch_comparator.sv\
    ./src/decode/register_file.sv\
    ./src/decode/immediate_generator.sv\
    ./src/decode/main_control_unit.sv\
    ./src/memory/data_memory.sv\
    ./src/core.sv\
    ./testbench/tb_core3.sv\
]

add_files -fileset sim_1 -norecurse ./src/program3.mem

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
puts "INFO: Setting compile order..."
set_property top tb_core3 [get_filesets sim_1]
update_compile_order -fileset sim_1

# --- 4. Launch Simulation ---
puts "INFO: Launching simulation..."
launch_simulation

# --- 5. Run Simulation ---
puts "INFO: Running simulation until \$finish..."
run -all

puts "INFO: Simulation stopped. Opening waveform GUI..."
start_gui

# --- 6. Clean Up ---
puts "INFO: Simulation finished. Closing project."
#close_project
#exit
