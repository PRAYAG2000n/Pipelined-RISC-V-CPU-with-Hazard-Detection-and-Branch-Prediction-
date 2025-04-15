module data_memory (
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:255]; // 1KB memory
    
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            mem[address[31:2]] <= write_data;
        end
    end
    
    always @(*) begin
        if (mem_read) begin
            read_data = mem[address[31:2]];
        end else begin
            read_data = 32'd0;
        end
    end
endmodule
