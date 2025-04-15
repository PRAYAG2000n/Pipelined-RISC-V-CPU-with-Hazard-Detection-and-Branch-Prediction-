module pipeline_reg_id_ex (
    input wire clk,
    input wire reset,
    input wire [31:0] pc_in,
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] immediate_in,
    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    input wire [4:0]  rd_in,
    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire [2:0]  alu_op_in,
    input wire alu_src_in,
    input wire branch_in,
    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg [2:0]  alu_op_out,
    output reg alu_src_out,
    output reg branch_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'd0;
            read_data1_out <= 32'd0;
            read_data2_out <= 32'd0;
            immediate_out <= 32'd0;
            rs1_out <= 5'd0;
            rs2_out <= 5'd0;
            rd_out <= 5'd0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_op_out <= 3'd0;
            alu_src_out <= 1'b0;
            branch_out <= 1'b0;
        end else begin
            pc_out <= pc_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            immediate_out <= immediate_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_op_out <= alu_op_in;
            alu_src_out <= alu_src_in;
            branch_out <= branch_in;
        end
    end
endmodule
