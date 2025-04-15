# Go to your project directory
cd "C:/Users/praya/Desktop/RISCV_CPU"

transcript on
onerror { puts "\n*** ERROR: See transcript above. GUI will remain open. ***\n" ; return }

# Clean simulation (without quitting the GUI)
quietly quit -sim
if {[file exists work]} { vdel -lib work -all }
vlib work


# Verilog RTL modules
vlog -cover bcesf +acc alu.v alu_control.v control_unit.v data_memory.v \
     immediate_generator.v instruction_memory.v pc_reg.v

# SystemVerilog modules (pipeline, hazard, predictor, core)
vlog -sv -cover bcesf +acc \
     hazard_unit.sv branch_predictor.sv \
     pipeline_reg_if_id.sv pipeline_reg_id_ex.sv pipeline_reg_ex_mem.sv pipeline_reg_mem_wb.sv \
     register_file.sv riscv_core.sv

# Testbench (SystemVerilog)
vlog -sv -cover bcesf +acc riscv_tb.sv


# Optimization & Simulation Setup
vopt +acc work.riscv_tb -o riscv_tb_opt
vsim -gui -coverage -onfinish stop riscv_tb_opt


# Waveform Setup
view wave
quietly catch {delete wave *}

# Basic signals
add wave sim:/riscv_tb/clk
add wave sim:/riscv_tb/reset
add wave -radix hex sim:/riscv_tb/uut/pc_if
add wave -radix hex sim:/riscv_tb/uut/pc_plus_4_if

# Branch predictor signals
add wave -radix hex sim:/riscv_tb/uut/bpu/predicted_pc
add wave -radix bin sim:/riscv_tb/uut/bpu/prediction_taken

# Actual branch decision
add wave -radix bin sim:/riscv_tb/uut/branch_ex
add wave -radix bin sim:/riscv_tb/uut/zero_ex

# Hazard control
add wave -radix bin sim:/riscv_tb/uut/hazard_detection/stall_id
add wave -radix bin sim:/riscv_tb/uut/hazard_detection/flush_id


# Simulation Run
run -all


# Coverage Report
coverage save riscv_cov.ucdb
coverage report -details -cvg

# Final View
# =========================================================
wave zoom full

