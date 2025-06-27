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
    ./src/1.fetch/IF_ID.sv \
    ./src/1.fetch/program_counter.sv \
    ./src/1.fetch/instruction_memory.sv \
    ./src/2.decode/ID_EX.sv \
    ./src/2.decode/immediate_sel.sv \
    ./src/2.decode/immediate_generator.sv \
    ./src/2.decode/main_control_unit.sv \
    ./src/2.decode/register_file.sv \
    ./src/3.execute/EX_MEM.sv \
    ./src/3.execute/alu.sv \
    ./src/3.execute/alu_control_unit.sv \
    ./src/4.memory/MEM_WB.sv \
    ./src/4.memory/data_memory.sv \
    ./src/5.writeback/write_back_sel.sv \
    ./src/6.hazard_processing/forwarding_unit.sv \
    ./src/riscv_pipeline_core.sv \
    ./testbench/tb_riscv_pipeline_core.sv \
]

add_files -fileset sim_1 -norecurse ./src/program.mem

# --- 3. Set Compile Order ---
# Explicitly set the defines package to be compiled first.
puts "INFO: Setting compile order..."
set_property top tb_riscv_pipeline_core [get_filesets sim_1]
update_compile_order -fileset sim_1

# --- 4. Launch Simulation ---
puts "INFO: Launching simulation..."
launch_simulation

# --- 5. Run Simulation ---
puts "INFO: Running simulation until \$finish..."
run -all

#puts "INFO: Simulation stopped. Opening waveform GUI..."
#start_gui

# --- 6. Clean Up ---
puts "INFO: Simulation finished. Closing project."
close_project
exit
