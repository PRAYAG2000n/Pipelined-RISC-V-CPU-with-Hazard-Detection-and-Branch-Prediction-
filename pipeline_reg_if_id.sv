module pipeline_reg_if_id (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_out <= 32'd0;
            instruction_out <= 32'd0;
        end else if (!stall) begin
            pc_out <= pc_in;
            instruction_out <= instruction_in;
        end
    end
endmodule
