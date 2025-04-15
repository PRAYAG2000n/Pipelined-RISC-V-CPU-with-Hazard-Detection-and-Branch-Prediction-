`timescale 1ns/1ps

// Testbench is SystemVerilog so we can use assertions and covergroups.
// Your RTL files can remain plain Verilog.
module riscv_tb;

  // ------------------------------------------------------------
  // Clock & Reset
  // ------------------------------------------------------------
  reg clk;
  reg reset;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 100 MHz
  end

  initial begin
    $display("Starting RISC-V CPU Simulation...");
    reset = 1'b1;
    #20;
    reset = 1'b0;
    $display("Reset released, starting program execution...");
  end

  // ------------------------------------------------------------
  // DUT (instance name MUST be 'uut' to match paths below)
  // ------------------------------------------------------------
  riscv_core uut (
    .clk   (clk),
    .reset (reset)
  );

  // ------------------------------------------------------------
  // Progress prints (PC trace every cycle)
  // ------------------------------------------------------------
  always @(posedge clk) if (!reset)
    $display("Time: %0t, PC: %08h", $time, uut.pc_if);

  // ------------------------------------------------------------
  // Simple counters for hazards/flushes (for summary)
  // ------------------------------------------------------------
  integer hazard_count, flush_count;
  initial begin
    hazard_count = 0;
    flush_count  = 0;
  end

  always @(posedge clk) begin
    if (!reset && uut.hazard_detection.stall_id) hazard_count++;
    if (!reset && uut.hazard_detection.flush_id) flush_count++;
  end
// =====================================================
// Functional coverage + simple assertions (SV-only)
// Safe signals only: pc_if, stall_id, flush_id
// =====================================================

// Assertions
always @(posedge clk) begin
  if (!reset) begin
    assert (uut.pc_if[1:0] == 2'b00)
      else $error("PC not word-aligned at %0t: %h", $time, uut.pc_if);
    assert (!(uut.hazard_detection.stall_id && uut.hazard_detection.flush_id))
      else $warning("stall & flush high together @%0t", $time);
  end
end

// Phase (optional)
typedef enum int {PHASE_RESET=0, PHASE_RUN=1} phase_e;
phase_e phase;
always @(posedge clk) begin
  if (reset) phase <= PHASE_RESET; else phase <= PHASE_RUN;
end

// >>> Sample hierarchical signals into locals (avoid part-select in cross)
logic [7:0] pc_idx;            // word index = pc_if[9:2]
logic       stall_s, flush_s;  // local copies of hazard bits
always @(posedge clk) begin
  pc_idx  <= uut.pc_if[9:2];
  stall_s <= uut.hazard_detection.stall_id;
  flush_s <= uut.hazard_detection.flush_id;
end

covergroup cg @(posedge clk);
  // PC progress bins
  coverpoint pc_idx {
    bins low   = {[0:8]};
    bins mid   = {[9:32]};
    bins high  = {[33:255]};
  }
  // Hazard events
  coverpoint stall_s { bins any_stall = {1'b1}; }
  coverpoint flush_s { bins any_flush = {1'b1}; }

  // Crosses (now against locals, not hierarchical part-selects)
  cross stall_s, pc_idx;
  cross flush_s, pc_idx;
endgroup

cg covi = new;

// Summary line
// Print coverage before we finish
  initial begin
	  @(negedge reset);
	  #1000; // happens before your #1020 finish
	  $display("Functional coverage (approx bins) = %0.2f%%", covi.get_coverage());
  end
  
  // ------------------------------------------------------------
  // End-of-run summary & finish (finite run)
  // ------------------------------------------------------------
  initial begin
    #1020;
    $display("\n--- TB Summary ---");
    $display("Hazard events : %0d", hazard_count);
    $display("Flush events  : %0d", flush_count);
    $display("------------------\n");
    $finish;
  end

endmodule



