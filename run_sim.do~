# Go to your project dir
cd "C:/Users/praya/Desktop/RISCV_CPU"

transcript on

# Keep GUI open on any error
onerror { puts "\n*** ERROR: See transcript above. GUI will remain open. ***\n" ; return }

# Fresh sim only (don’t quit the whole app)
quietly quit -sim
if {[file exists work]} { vdel -lib work -all }
vlib work

# ---------------------------
# Compile RTL
# ---------------------------

# Verilog-only sources
vlog -cover bcesf +acc alu.v alu_control.v control_unit.v data_memory.v hazard_unit.v \
     immediate_generator.v instruction_memory.v pc_reg.v \
     pipeline_reg_ex_mem.v pipeline_reg_id_ex.v pipeline_reg_if_id.v \
     pipeline_reg_mem_wb.v register_file.v branch_predictor.v

# SystemVerilog RTL (riscv_core is SV even if extension is .v)
vlog -sv -cover bcesf +acc riscv_core.v

# Testbench (SystemVerilog)
vlog -sv -cover bcesf +acc riscv_tb.sv

# ---------------------------
# Optimize & simulate
# ---------------------------
vopt +acc work.riscv_tb -o riscv_tb_opt
vsim -gui -coverage -onfinish stop riscv_tb_opt

# ---------------------------
# Wave setup
# ---------------------------
view wave
quietly catch {delete wave *}

add wave sim:/riscv_tb/clk
add wave sim:/riscv_tb/reset
add wave -radix hex  sim:/riscv_tb/uut/pc_if
add wave -radix hex  sim:/riscv_tb/uut/pc_plus_4_if

# From the predictor (instance name: bpu)
add wave -radix hex  sim:/riscv_tb/uut/bpu/predicted_pc
add wave -radix bin  sim:/riscv_tb/uut/bpu/prediction_taken

# Actual branch decision in EX (to compare vs prediction)
add wave -radix bin  sim:/riscv_tb/uut/branch_ex
add wave -radix bin  sim:/riscv_tb/uut/zero_ex

add wave -radix bin  sim:/riscv_tb/uut/hazard_detection/stall_id
add wave -radix bin  sim:/riscv_tb/uut/hazard_detection/flush_id

# ---------------------------
# Run
# ---------------------------
run -all

# ---------------------------
# Coverage
# ---------------------------
coverage save riscv_cov.ucdb
coverage report -details -cvg

wave zoom full

