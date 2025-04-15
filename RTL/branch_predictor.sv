module branch_predictor (
    input  wire         clk,
    input  wire         reset,
    input  wire [31:0]  pc_if,          // Current PC from IF stage
    input  wire [31:0]  branch_pc_ex,   // Branch PC resolved in EX stage
    input  wire [31:0]  branch_target_ex, // Actual target computed in EX
    input  wire         branch_taken_ex,  // Actual branch result
    input  wire         branch_valid_ex,  // Asserted when EX has a valid branch
    output reg  [31:0]  predicted_pc,   // Predicted next PC
    output reg          prediction_taken // Whether predictor thinks branch will be taken
);

    // BTB and predictor tables (16-entry direct-mapped)
    reg [31:0] btb_pc [0:15];
    reg [31:0] btb_target [0:15];
    reg        btb_valid [0:15];
    reg        predict_bit [0:15];  // 1-bit predictor: 1=taken, 0=not taken

    wire [3:0] index_if = pc_if[5:2];       // Simple index from lower bits
    wire [3:0] index_ex = branch_pc_ex[5:2]; // Same index for EX update

    // IF stage prediction
    always @(*) begin
        if (btb_valid[index_if] && btb_pc[index_if] == pc_if && predict_bit[index_if]) begin
            predicted_pc     = btb_target[index_if];
            prediction_taken = 1'b1;
        end else begin
            predicted_pc     = pc_if + 4;
            prediction_taken = 1'b0;
        end
    end

    // Update predictor after actual branch outcome
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                btb_valid[i]  <= 1'b0;
                btb_pc[i]     <= 32'b0;
                btb_target[i] <= 32'b0;
                predict_bit[i]<= 1'b0;
            end
        end else if (branch_valid_ex) begin
            btb_valid[index_ex]  <= 1'b1;
            btb_pc[index_ex]     <= branch_pc_ex;
            btb_target[index_ex] <= branch_target_ex;
            predict_bit[index_ex]<= branch_taken_ex;  // Update 1-bit predictor
        end
    end

endmodule

