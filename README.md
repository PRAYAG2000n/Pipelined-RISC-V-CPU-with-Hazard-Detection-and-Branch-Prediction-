# Pipelined RISC-V CPU (Verilog / SystemVerilog)

This project implements a **6-stage pipelined RISC-V CPU** with hazard detection, data forwarding, and a lightweight **branch predictor**.  
Simulation, waveform generation, and coverage reporting are automated using **ModelSim / QuestaSim** with `run_sim.do`.

---
## Features

- ✅ **6 Pipeline Stages:** IF → ID → EX → MEM → WB (+ hazard unit)  
- ⚡ **Data Hazards:** Handled via forwarding (EX/MEM → EX) and stall logic  
- 🔁 **Control Hazards:** Managed with a simple **2-bit branch predictor (BPU)**  
- 🧠 **Functional Coverage:** Tracks pipeline stalls, flushes, and PC progression  
- 🧩 **Assertions:** Detects misaligned PC or invalid stall+flush conditions  
- 🧮 **Automated Simulation:** TCL script compiles, runs, and reports coverage  
- 🎯 Achieved **100% functional coverage** under directed simulation
---

## Repository Structure
- alu.v
- alu_control.v
- branch_predictor.v
- control_unit.v
- data_memory.v
- hazard_unit.v
- immediate_generator.v
- instruction_memory.v
- pc_reg.v
- pipeline_reg_if_id.v
- pipeline_reg_id_ex.v
- pipeline_reg_ex_mem.v
- pipeline_reg_mem_wb.v
- register_file.v
- riscv_core.v # Top-level CPU (SystemVerilog-compatible)
- riscv_tb.sv # Testbench: assertions + functional coverage
- run_sim.do # Automates build, simulation, and coverage reporting

---

## Run Simulation (ModelSim / QuestaSim)

From the project directory:

```tcl
do run_sim.do
```
This performs:
- Cleans workspace (vdel, vlib, etc.)
- Compiles Verilog + SystemVerilog sources
- Launches simulation in GUI
- Runs full testbench
- Generates coverage report
---
## Functional Coverage & Assertions
**Coverage:**
Implemented via SystemVerilog covergroups (riscv_tb.sv) tracking:
- stall_id, flush_id activation bins
- PC progress (low, mid, high regions)
- Cross coverage: (stall/flush × PC range)
**Assertions:**
- Checks that the program counter (pc_if) is word-aligned
- Warns when both stall_id and flush_id are high simultaneously
---
## Branch Predictor
File: branch_predictor.v
The predictor uses simple taken/not-taken history with immediate training feedback:
- Prediction phase (IF): Provides predicted next PC and “taken” flag
- Training phase (EX): Updates predictor on actual branch outcome (branch_ex & zero_ex)
- On mispredict: Flush signal triggered via hazard unit
---
**Waveform view:**
<img width="1598" height="511" alt="Screenshot 2025-10-26 113441" src="https://github.com/user-attachments/assets/9b9519cb-befb-477a-8299-f492e978e114" />
---
## Output
<pre> <code> ```text run -all Starting RISC-V CPU Simulation...
Reset released, starting program execution...
Time: 25000, PC: 00000000
Time: 35000, PC: 00000004
Time: 45000, PC: 00000008
Time: 55000, PC: 0000000c
Time: 65000, PC: 00000010
Time: 75000, PC: 00000014
Time: 85000, PC: 00000018
** Warning: stall & flush high together @95000
   Time: 95 ns  Scope: riscv_tb File: riscv_tb.sv Line: 45
Time: 95000, PC: 0000001c
Time: 105000, PC: 0000001c
Time: 115000, PC: 00000020
Time: 125000, PC: 00000024
Time: 135000, PC: 00000028
Time: 145000, PC: 0000002c
** Warning: stall & flush high together @155000
   Time: 155 ns  Scope: riscv_tb File: riscv_tb.sv Line: 45
Time: 155000, PC: 00000030
Time: 165000, PC: 00000030
Time: 175000, PC: 00000034
Time: 185000, PC: 00000038
Time: 195000, PC: 0000003c
Time: 205000, PC: 00000040
Time: 215000, PC: 00000044
Time: 225000, PC: 00000048
Time: 235000, PC: 0000004c
Time: 245000, PC: 00000050
Time: 255000, PC: 00000054
Time: 265000, PC: 00000058
** Warning: stall & flush high together @265000
   Time: 265 ns  Scope: riscv_tb File: riscv_tb.sv Line: 45
Time: 275000, PC: 00000058
Time: 285000, PC: 0000005c
Time: 295000, PC: 00000060
Time: 305000, PC: 00000064
Time: 315000, PC: 00000068
Time: 325000, PC: 0000006c
Time: 335000, PC: 00000070
Time: 345000, PC: 00000074
Time: 355000, PC: 00000078
Time: 365000, PC: 0000007c
Time: 375000, PC: 00000080
Time: 385000, PC: 00000084
Time: 395000, PC: 00000088
Time: 405000, PC: 0000008c
Time: 415000, PC: 00000090
Time: 425000, PC: 00000094
Time: 435000, PC: 00000098
Time: 445000, PC: 0000009c
Time: 455000, PC: 000000a0
Time: 465000, PC: 000000a4
** Warning: stall & flush high together @475000
   Time: 475 ns  Scope: riscv_tb File: riscv_tb.sv Line: 45
Time: 475000, PC: 000000a8
Time: 485000, PC: 000000a8
Time: 495000, PC: 000000ac
Time: 505000, PC: 000000b0
Time: 515000, PC: 000000b4
Time: 525000, PC: 000000b8
Time: 535000, PC: 000000bc
Time: 545000, PC: 000000c0
Time: 555000, PC: 000000c4
Time: 565000, PC: 000000c8
Time: 575000, PC: 000000cc
Time: 585000, PC: 000000d0
** Warning: stall & flush high together @585000
   Time: 585 ns  Scope: riscv_tb File: riscv_tb.sv Line: 45
Time: 595000, PC: 000000d0
Time: 605000, PC: 000000d4
Time: 615000, PC: 000000d8
Time: 625000, PC: 000000dc
Time: 635000, PC: 000000e0
Time: 645000, PC: 000000e4
Time: 655000, PC: 000000e8
Time: 665000, PC: 000000ec
Time: 675000, PC: 000000f0
Time: 685000, PC: 000000f4
Time: 695000, PC: 000000f8
Time: 705000, PC: 000000fc
Time: 715000, PC: 00000100
Time: 725000, PC: 00000104
Time: 735000, PC: 00000108
Time: 745000, PC: 0000010c
Time: 755000, PC: 00000110
Time: 765000, PC: 00000114
Time: 775000, PC: 00000118
Time: 785000, PC: 0000011c
Time: 795000, PC: 00000120
Time: 805000, PC: 00000124
Time: 815000, PC: 00000128
Time: 825000, PC: 0000012c
Time: 835000, PC: 00000130
Time: 845000, PC: 00000134
Time: 855000, PC: 00000138
Time: 865000, PC: 0000013c
Time: 875000, PC: 00000140
Time: 885000, PC: 00000144
Time: 895000, PC: 00000148
Time: 905000, PC: 0000014c
Time: 915000, PC: 00000150
Time: 925000, PC: 00000154
Time: 935000, PC: 00000158
Time: 945000, PC: 0000015c
Time: 955000, PC: 00000160
Time: 965000, PC: 00000164
Time: 975000, PC: 00000168
Time: 985000, PC: 0000016c
Time: 995000, PC: 00000170
Time: 1005000, PC: 00000174
Time: 1015000, PC: 00000178

TB Summary
Hazard events : 5
Flush events  : 5


** Note: $finish    : riscv_tb.sv(96)
   Time: 1020 ns  Iteration: 0  Instance: /riscv_tb
Break in Module riscv_tb at riscv_tb.sv line 96


Coverage Report
coverage save riscv_cov.ucdb
coverage report -details -cvg

COVERGROUP COVERAGE:
-----------------------------------------------------------------------------------------------
Covergroup                                             Metric       Goal    Status
-----------------------------------------------------------------------------------------------
TYPE /riscv_tb/cg                                    100.00%        100    Covered
    covered/total bins:                                    11         11
    missing/total bins:                                     0         11
    % Hit:                                            100.00%        100
    Coverpoint cg::pc_idx                             100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
    Coverpoint cg::stall_s                            100.00%        100    Covered
        covered/total bins:                                 1          1
        missing/total bins:                                 0          1
        % Hit:                                        100.00%        100
    Coverpoint cg::flush_s                            100.00%        100    Covered
        covered/total bins:                                 1          1
        missing/total bins:                                 0          1
        % Hit:                                        100.00%        100
    Cross cg::#cross__0#                              100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
    Cross cg::#cross__1#                              100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
Covergroup instance /riscv_tb/covi                   100.00%        100    Covered
    covered/total bins:                                    11         11
    missing/total bins:                                     0         11
    % Hit:                                            100.00%        100
    Coverpoint pc_idx                                 100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
        bin low                                            12          1    Covered
        bin mid                                            26          1    Covered
        bin high                                           63          1    Covered
    Coverpoint stall_s                                100.00%        100    Covered
        covered/total bins:                                 1          1
        missing/total bins:                                 0          1
        % Hit:                                        100.00%        100
        bin any_stall                                       5          1    Covered
    Coverpoint flush_s                                100.00%        100    Covered
        covered/total bins:                                 1          1
        missing/total bins:                                 0          1
        % Hit:                                        100.00%        100
        bin any_flush                                       5          1    Covered
    Cross #cross__0#                                  100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
        bin <any_stall,low>                                 1          1    Covered
        bin <any_stall,mid>                                 2          1    Covered
        bin <any_stall,high>                                2          1    Covered
    Cross #cross__1#                                  100.00%        100    Covered
        covered/total bins:                                 3          3
        missing/total bins:                                 0          3
        % Hit:                                        100.00%        100
        bin <any_flush,low>                                 1          1    Covered
        bin <any_flush,mid>                                 2          1    Covered
        bin <any_flush,high>                                2          1    Covered

TOTAL COVERGROUP COVERAGE: 100.00%  COVERGROUP TYPES: 1

Final View
wave zoom full
0 ps
1071 ns
```</code> </pre>
_


