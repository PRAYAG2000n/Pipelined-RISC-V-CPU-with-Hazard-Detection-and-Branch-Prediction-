// ===============================================================
// instruction_memory.v
// 256 x 32-bit instruction memory (ROM style)
// Compatible with ModelSim/QuestaSim Verilog-2001
// Designed to increase functional coverage for stall/flush tests
// ===============================================================

module instruction_memory (
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    // ---------------------------------------------------------------
    // 1 KB memory: 256 words × 4 bytes
    // ---------------------------------------------------------------
    reg [31:0] mem [0:255];
    integer i;

    initial begin
        // -----------------------------------------------------------
        // Default all words to NOP: addi x0, x0, 0 (0x00000013)
        // -----------------------------------------------------------
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'h00000013;
        end

        // -----------------------------------------------------------
        // Base program (Low range: 0–8)
        // -----------------------------------------------------------
        mem[0] = 32'h00500093; // addi x1, x0, 5
        mem[1] = 32'h00300113; // addi x2, x0, 3
        mem[2] = 32'h002081b3; // add x3, x1, x2
        mem[3] = 32'h00208233; // add x4, x1, x2
        mem[4] = 32'h004182b3; // add x5, x3, x4
        mem[5] = 32'h00002303; // lw  x6, 0(x0)
        mem[6] = 32'h00602423; // sw  x6, 8(x0)
        mem[7] = 32'h00100093; // addi x1, x0, 1
        mem[8] = 32'h00200113; // addi x2, x0, 2

        // -----------------------------------------------------------
        // Mid range (addresses ~9–32)
        // Add deliberate load-use and branch to trigger stall/flush
        // -----------------------------------------------------------
        mem[10] = 32'h00002303; // lw  x6, 0(x0)
        mem[11] = 32'h000303b3; // add x7, x6, x0 (use x6 immediately -> stall)
        mem[12] = 32'h00108463; // beq x1, x1, +8 (always taken -> flush)
        mem[13] = 32'h00000013; // nop (delay slot)
        mem[20] = 32'h00002483; // lw  x9, 0(x0)
        mem[21] = 32'h0094a4b3; // add x9, x9, x9 (force hazard)
        mem[22] = 32'h00000013; // nop
        mem[24] = 32'h00108463; // beq x1, x1, +8 (taken -> flush again)
        mem[25] = 32'h00000013; // nop

        // -----------------------------------------------------------
        // High range (>32)
        // Repeat hazards to fill coverage bins
        // -----------------------------------------------------------
        mem[40] = 32'h00002303; // lw  x6, 0(x0)
        mem[41] = 32'h000303b3; // add x7, x6, x0
        mem[42] = 32'h00108463; // beq x1, x1, +8
        mem[43] = 32'h00000013; // nop
        mem[50] = 32'h00002483; // lw  x9, 0(x0)
        mem[51] = 32'h0094a4b3; // add x9, x9, x9
        mem[52] = 32'h00000013; // nop
        mem[60] = 32'h00108463; // beq x1, x1, +8
        mem[61] = 32'h00000013; // nop

        // -----------------------------------------------------------
        // Very high range (>100)
        // Adds variety to PC bins to saturate cross coverage
        // -----------------------------------------------------------
        mem[100] = 32'h00002503; // lw  x10, 0(x0)
        mem[101] = 32'h00a50533; // add x10, x10, x10
        mem[102] = 32'h00108663; // beq x1, x1, +12
        mem[103] = 32'h00000013; // nop
        mem[104] = 32'h00000013; // nop
        mem[120] = 32'h00002583; // lw  x11, 0(x0)
        mem[121] = 32'h00b585b3; // add x11, x11, x11
        mem[122] = 32'h00108663; // beq x1, x1, +12
        mem[123] = 32'h00000013; // nop
        mem[124] = 32'h00000013; // nop

        // -----------------------------------------------------------
        // End program (optional halt loop)
        // -----------------------------------------------------------
        mem[250] = 32'h00000013; // nop
        mem[251] = 32'h00000013; // nop
        mem[252] = 32'h00000013; // nop
        mem[253] = 32'h00000013; // nop
        mem[254] = 32'h00000013; // nop
        mem[255] = 32'h00000013; // nop
    end

    // ---------------------------------------------------------------
    // Word-aligned fetch
    // ---------------------------------------------------------------
    always @(*) begin
        instruction = mem[address[31:2]];
    end

endmodule

