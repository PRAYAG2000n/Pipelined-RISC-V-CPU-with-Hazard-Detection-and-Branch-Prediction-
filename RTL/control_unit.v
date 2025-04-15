module control_unit (
    input wire [6:0] opcode,
    
    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_to_reg,
    output reg [2:0] alu_op,
    output reg       alu_src,
    output reg       branch
);
    
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 3'b010;
                alu_src   = 1'b0;
                branch    = 1'b0;
            end
            7'b0010011: begin // I-type (ADDI)
                reg_write = 1'b1;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 3'b011;
                alu_src   = 1'b1;
                branch    = 1'b0;
            end
            7'b0000011: begin // LOAD
                reg_write = 1'b1;
                mem_read  = 1'b1;
                mem_write = 1'b0;
                mem_to_reg = 1'b1;
                alu_op    = 3'b000;
                alu_src   = 1'b1;
                branch    = 1'b0;
            end
            7'b0100011: begin // STORE
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b1;
                mem_to_reg = 1'b0;
                alu_op    = 3'b000;
                alu_src   = 1'b1;
                branch    = 1'b0;
            end
            7'b1100011: begin // BRANCH
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 3'b001;
                alu_src   = 1'b0;
                branch    = 1'b1;
            end
            default: begin
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 3'b000;
                alu_src   = 1'b0;
                branch    = 1'b0;
            end
        endcase
    end

endmodule
