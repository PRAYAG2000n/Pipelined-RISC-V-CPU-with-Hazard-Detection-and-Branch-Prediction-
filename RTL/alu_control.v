module alu_control (
    input wire [2:0] alu_op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_control
);
    always @(*) begin
        case (alu_op)
            3'b000: alu_control = 4'b0010; // LW/SW - ADD
            3'b001: alu_control = 4'b0110; // BRANCH - SUB
            3'b010: begin // R-type
                case (funct3)
                    3'b000: alu_control = (funct7[5] ? 4'b0110 : 4'b0010); // ADD/SUB
                    3'b111: alu_control = 4'b0000; // AND
                    3'b110: alu_control = 4'b0001; // OR
                    3'b001: alu_control = 4'b0010; // SLL
                    default: alu_control = 4'b0010;
                endcase
            end
            3'b011: alu_control = 4'b0010; // ADDI - ADD
            default: alu_control = 4'b0010;
        endcase
    end
endmodule
