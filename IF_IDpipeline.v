module if_id_stage (
    input               clk,          // Clock
    input               reset,        // Async reset
    input               stall,        // Stall signal (from hazard unit)
    input               flush,        // Flush signal (e.g., branch misprediction)
    input        [31:0] pc,           // Current PC from IF stage
    input        [31:0] instr,        // Fetched instruction from memory
    output reg   [31:0] if_id_pc,     // Registered PC to ID stage
    output reg   [31:0] if_id_instr   // Registered instruction to ID stage
);

  // NOP instruction: addi x0, x0, 0 (used for flushing)
  localparam NOP = 32'h00000013;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset to safe defaults
      if_id_pc    <= 32'h0;
      if_id_instr <= NOP;
    end else if (flush) begin
      // Flush: Insert NOP, retain PC for debugging (optional)
      if_id_instr <= NOP;
      // if_id_pc <= 32'h0;  // Uncomment to clear PC on flush
    end else if (!stall) begin
      // Normal operation: Propagate PC and instruction
      if_id_pc    <= pc;
      if_id_instr <= instr;
    end
    // If stalled, registers retain their values implicitly
  end

endmodule
