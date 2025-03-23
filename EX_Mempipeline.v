module ex_mem_stage (
    input               clk,          // Clock
    input               reset,        // Async reset
    input               stall,        // Stall signal (from hazard unit)
    input               flush,        // Flush signal (e.g., branch mispredict)
    // Data inputs from EX stage
    input        [31:0] ex_alu_result, // ALU computation result
    input        [31:0] ex_mem_write_data, // Data to write to memory (for stores)
    input        [4:0]  ex_rd,         // Destination register
    // Control inputs from EX stage
    input               ex_mem_write,  // Memory write enable
    input               ex_mem_read,   // Memory read enable
    input               ex_reg_write,  // Register write enable
    // Outputs to MEM stage
    output reg   [31:0] ex_mem_alu_result,
    output reg   [31:0] ex_mem_mem_write_data,
    output reg   [4:0]  ex_mem_rd,
    output reg          ex_mem_mem_write,
    output reg          ex_mem_mem_read,
    output reg          ex_mem_reg_write
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers to safe defaults
      ex_mem_alu_result      <= 0;
      ex_mem_mem_write_data  <= 0;
      ex_mem_rd              <= 0;
      ex_mem_mem_write       <= 0;
      ex_mem_mem_read        <= 0;
      ex_mem_reg_write       <= 0;
    end else if (flush) begin
      // Insert bubble: Disable control signals
      ex_mem_mem_write       <= 0;
      ex_mem_mem_read        <= 0;
      ex_mem_reg_write       <= 0;
    end else if (!stall) begin
      // Propagate data and control signals
      ex_mem_alu_result      <= ex_alu_result;
      ex_mem_mem_write_data  <= ex_mem_write_data;
      ex_mem_rd              <= ex_rd;
      ex_mem_mem_write       <= ex_mem_write;
      ex_mem_mem_read        <= ex_mem_read;
      ex_mem_reg_write       <= ex_reg_write;
    end
    // If stalled, retain current values
  end

endmodule
