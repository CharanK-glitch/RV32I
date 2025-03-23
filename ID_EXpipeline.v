module id_ex_stage (
    input               clk,          // Clock
    input               reset,        // Async reset
    input               stall,        // Stall signal (from hazard unit)
    input               flush,        // Flush signal (e.g., branch mispredict)
    // Data inputs from ID stage
    input        [31:0] id_pc,        // PC from ID stage
    input        [31:0] id_rs1_data,  // Register read data 1
    input        [31:0] id_rs2_data,  // Register read data 2
    input        [31:0] id_imm,       // Immediate value
    input        [4:0]  id_rs1,       // Rs1 address (for forwarding)
    input        [4:0]  id_rs2,       // Rs2 address (for forwarding)
    input        [4:0]  id_rd,        // Destination register
    // Control inputs from ID stage
    input        [2:0]  id_alu_ctrl,  // ALU operation (e.g., ADD, SUB)
    input               id_alu_src,   // ALU source (0=reg, 1=imm)
    input               id_mem_write, // Memory write enable
    input               id_mem_read,  // Memory read enable
    input               id_reg_write, // Register write enable
    // Outputs to EX stage
    output reg   [31:0] ex_pc,        // PC to EX stage
    output reg   [31:0] ex_rs1_data,
    output reg   [31:0] ex_rs2_data,
    output reg   [31:0] ex_imm,
    output reg   [4:0]  ex_rs1,
    output reg   [4:0]  ex_rs2,
    output reg   [4:0]  ex_rd,
    output reg   [2:0]  ex_alu_ctrl,
    output reg          ex_alu_src,
    output reg          ex_mem_write,
    output reg          ex_mem_read,
    output reg          ex_reg_write
);

  // Flush behavior: Insert NOP by zeroing control signals
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers
      ex_pc         <= 0;
      ex_rs1_data   <= 0;
      ex_rs2_data   <= 0;
      ex_imm        <= 0;
      ex_rs1        <= 0;
      ex_rs2        <= 0;
      ex_rd         <= 0;
      ex_alu_ctrl   <= 0;
      ex_alu_src    <= 0;
      ex_mem_write  <= 0;
      ex_mem_read   <= 0;
      ex_reg_write  <= 0;
    end else if (flush) begin
      // Insert bubble: Keep data paths (optional), disable control signals
      ex_alu_ctrl   <= 0;
      ex_alu_src    <= 0;
      ex_mem_write  <= 0;
      ex_mem_read   <= 0;
      ex_reg_write  <= 0;
    end else if (!stall) begin
      // Propagate data and control signals
      ex_pc         <= id_pc;
      ex_rs1_data   <= id_rs1_data;
      ex_rs2_data   <= id_rs2_data;
      ex_imm        <= id_imm;
      ex_rs1        <= id_rs1;
      ex_rs2        <= id_rs2;
      ex_rd         <= id_rd;
      ex_alu_ctrl   <= id_alu_ctrl;
      ex_alu_src    <= id_alu_src;
      ex_mem_write  <= id_mem_write;
      ex_mem_read   <= id_mem_read;
      ex_reg_write  <= id_reg_write;
    end
    // If stalled, registers retain their values implicitly
  end

endmodule
