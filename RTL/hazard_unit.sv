module hazard_unit (
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    input wire [4:0] rs1_ex,
    input wire [4:0] rs2_ex,
    input wire [4:0] rd_ex,
    input wire [4:0] rd_mem,
    input wire [4:0] rd_wb,
    input wire reg_write_ex,
    input wire reg_write_mem,
    input wire reg_write_wb,
    input wire mem_read_ex,
    
    output reg stall_if,
    output reg stall_id,
    output reg flush_id,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    
    // Load-Use Hazard Detection
    always @(*) begin
        stall_if = 1'b0;
        stall_id = 1'b0;
        flush_id = 1'b0;
        
        // Load-Use Hazard: When EX stage is LW and destination register is used in ID
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
            flush_id = 1'b1;
        end
    end
    
    // Forwarding Unit
    always @(*) begin
        // Forward A (EX stage)
        if ((rs1_ex != 0) && (rs1_ex == rd_mem) && reg_write_mem)
            forward_a = 2'b10; // Forward from MEM stage
        else if ((rs1_ex != 0) && (rs1_ex == rd_wb) && reg_write_wb)
            forward_a = 2'b01; // Forward from WB stage
        else
            forward_a = 2'b00; // No forwarding
            
        // Forward B (EX stage)
        if ((rs2_ex != 0) && (rs2_ex == rd_mem) && reg_write_mem)
            forward_b = 2'b10; // Forward from MEM stage
        else if ((rs2_ex != 0) && (rs2_ex == rd_wb) && reg_write_wb)
            forward_b = 2'b01; // Forward from WB stage
        else
            forward_b = 2'b00; // No forwarding
    end

endmodule
