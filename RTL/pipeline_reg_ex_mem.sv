module pipeline_reg_ex_mem (
    input wire clk,
    input wire reset,
    input wire [31:0] alu_result_in,
    input wire [31:0] write_data_in,
    input wire [4:0]  rd_in,
    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire zero_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0]  rd_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg zero_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'd0;
            write_data_out <= 32'd0;
            rd_out <= 5'd0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            zero_out <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            zero_out <= zero_in;
        end
    end
endmodule
