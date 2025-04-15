module riscv_core (
    input wire clk,
    input wire reset
);
    
    // Pipeline stage wires
    // IF Stage
    wire [31:0] pc_if, pc_plus_4_if, instruction_if;
    
    // IF/ID Pipeline Register
    wire [31:0] pc_id, instruction_id;
    
    // ID Stage
    wire [31:0] read_data1_id, read_data2_id, immediate_id;
    wire [4:0]  rs1_id, rs2_id, rd_id;
    wire        reg_write_id, mem_read_id, mem_write_id, mem_to_reg_id;
    wire [2:0]  alu_op_id;
    wire        alu_src_id, branch_id;
    
    // ID/EX Pipeline Register
    wire [31:0] pc_ex, read_data1_ex, read_data2_ex, immediate_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire        reg_write_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex;
    wire [2:0]  alu_op_ex;
    wire        alu_src_ex, branch_ex;
    
    // EX Stage
    wire [31:0] alu_result_ex, write_data_ex;
    wire [3:0]  alu_control_ex;  // Changed from wire to 4-bit
    wire        zero_ex;
    wire [4:0]  rd_ex_out;
    
    // EX/MEM Pipeline Register
    wire [31:0] alu_result_mem, write_data_mem;
    wire [4:0]  rd_mem;
    wire        reg_write_mem, mem_read_mem, mem_write_mem, mem_to_reg_mem;
    wire        zero_mem;
    
    // MEM Stage
    wire [31:0] read_data_mem;
    
    // MEM/WB Pipeline Register
    wire [31:0] alu_result_wb, read_data_wb;
    wire [4:0]  rd_wb;
    wire        reg_write_wb, mem_to_reg_wb;
    
    // WB Stage
    wire [31:0] write_back_data;
    
    // Hazard Detection
    wire stall_if, stall_id, flush_id;
    wire [1:0] forward_a_ex, forward_b_ex;
    
    // Forwarded data
    wire [31:0] read_data2_forwarded;

    // Branch predictor I/F
    wire [31:0] predicted_pc;
    wire        prediction_taken;
    
    // ==================== PIPELINE STAGES ====================
    // Simple +4 (kept for reference; predictor chooses final next PC)
    assign pc_plus_4_if = pc_if + 32'd4;
    
    // --- Branch Predictor (new) ---
    // Trains on EX decision: "taken" when branch_ex & zero_ex (BEQ-like)
    branch_predictor bpu (
        .clk              (clk),
        .reset            (reset),
        .pc_if            (pc_if),
        .branch_pc_ex     (pc_ex),
        .branch_target_ex (pc_ex + immediate_ex),
        .branch_taken_ex  (branch_ex & zero_ex),
        .branch_valid_ex  (branch_ex),
        .predicted_pc     (predicted_pc),
        .prediction_taken (prediction_taken)
    );


    // === IF Stage ===
    pc_reg pc_stage (
        .clk(clk),
        .reset(reset),
        .stall(stall_if),
        .pc_next(pc_plus_4_if),
        .pc(pc_if)
    );
    
    instruction_memory imem (
        .address(pc_if),
        .instruction(instruction_if)
    );
    
    
    // IF/ID Pipeline Register
    pipeline_reg_if_id if_id_reg (
        .clk(clk),
        .reset(reset),
        .stall(stall_id),
        .flush(flush_id),
        .pc_in(pc_if),
        .instruction_in(instruction_if),
        .pc_out(pc_id),
        .instruction_out(instruction_id)
    );
    
    // === ID Stage ===
    assign rs1_id = instruction_id[19:15];
    assign rs2_id = instruction_id[24:20];
    assign rd_id  = instruction_id[11:7];
    
    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1_id),
        .read_reg2(rs2_id),
        .write_reg(rd_wb),
        .write_data(write_back_data),
        .reg_write(reg_write_wb),
        .read_data1(read_data1_id),
        .read_data2(read_data2_id)
    );
    
    control_unit control (
        .opcode(instruction_id[6:0]),
        .reg_write(reg_write_id),
        .mem_read(mem_read_id),
        .mem_write(mem_write_id),
        .mem_to_reg(mem_to_reg_id),
        .alu_op(alu_op_id),
        .alu_src(alu_src_id),
        .branch(branch_id)
    );
    
    immediate_generator imm_gen (
        .instruction(instruction_id),
        .immediate(immediate_id)
    );
    
    // ID/EX Pipeline Register
    pipeline_reg_id_ex id_ex_reg (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_id),
        .read_data1_in(read_data1_id),
        .read_data2_in(read_data2_id),
        .immediate_in(immediate_id),
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        .reg_write_in(reg_write_id),
        .mem_read_in(mem_read_id),
        .mem_write_in(mem_write_id),
        .mem_to_reg_in(mem_to_reg_id),
        .alu_op_in(alu_op_id),
        .alu_src_in(alu_src_id),
        .branch_in(branch_id),
        .pc_out(pc_ex),
        .read_data1_out(read_data1_ex),
        .read_data2_out(read_data2_ex),
        .immediate_out(immediate_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex),
        .reg_write_out(reg_write_ex),
        .mem_read_out(mem_read_ex),
        .mem_write_out(mem_write_ex),
        .mem_to_reg_out(mem_to_reg_ex),
        .alu_op_out(alu_op_ex),
        .alu_src_out(alu_src_ex),
        .branch_out(branch_ex)
    );
    
    // === EX Stage ===
    hazard_unit hazard_detection (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .reg_write_ex(reg_write_ex),
        .reg_write_mem(reg_write_mem),
        .reg_write_wb(reg_write_wb),
        .mem_read_ex(mem_read_ex),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .flush_id(flush_id),
        .forward_a(forward_a_ex),
        .forward_b(forward_b_ex)
    );
    
    alu alu_unit (
        .a(write_data_ex),
        .b(alu_src_ex ? immediate_ex : read_data2_forwarded),
        .alu_control(alu_control_ex),
        .result(alu_result_ex),
        .zero(zero_ex)
    );
    
    alu_control alu_ctrl (
        .alu_op(alu_op_ex),
        .funct3(instruction_id[14:12]),
        .funct7(instruction_id[31:25]),
        .alu_control(alu_control_ex)
    );
    
    // Forwarding MUXes
    assign write_data_ex = (forward_a_ex == 2'b10) ? alu_result_mem :
                          (forward_a_ex == 2'b01) ? write_back_data : read_data1_ex;
    
    assign read_data2_forwarded = (forward_b_ex == 2'b10) ? alu_result_mem :
                                 (forward_b_ex == 2'b01) ? write_back_data : read_data2_ex;
    
    // EX/MEM Pipeline Register
    pipeline_reg_ex_mem ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result_ex),
        .write_data_in(read_data2_forwarded),  // Fixed connection
        .rd_in(rd_ex),
        .reg_write_in(reg_write_ex),
        .mem_read_in(mem_read_ex),
        .mem_write_in(mem_write_ex),
        .mem_to_reg_in(mem_to_reg_ex),
        .zero_in(zero_ex),
        .alu_result_out(alu_result_mem),
        .write_data_out(write_data_mem),
        .rd_out(rd_mem),
        .reg_write_out(reg_write_mem),
        .mem_read_out(mem_read_mem),
        .mem_write_out(mem_write_mem),
        .mem_to_reg_out(mem_to_reg_mem),
        .zero_out(zero_mem)
    );
    
    // === MEM Stage ===
    data_memory dmem (
        .clk(clk),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .address(alu_result_mem),
        .write_data(write_data_mem),
        .read_data(read_data_mem)
    );
    
    // MEM/WB Pipeline Register
    pipeline_reg_mem_wb mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result_mem),
        .read_data_in(read_data_mem),
        .rd_in(rd_mem),
        .reg_write_in(reg_write_mem),
        .mem_to_reg_in(mem_to_reg_mem),
        .alu_result_out(alu_result_wb),
        .read_data_out(read_data_wb),
        .rd_out(rd_wb),
        .reg_write_out(reg_write_wb),
        .mem_to_reg_out(mem_to_reg_wb)
    );
    
    // === WB Stage ===
    assign write_back_data = mem_to_reg_wb ? read_data_wb : alu_result_wb;

endmodule
