module pc_reg (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] pc_next,
    output reg [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
        end else if (!stall) begin
            pc <= pc_next;
        end
    end
endmodule
