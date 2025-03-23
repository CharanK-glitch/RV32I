module instruction_memory (
    input               clk,          // Clock
    input        [31:0] addr,         // Byte address (word-aligned for RV32I)
    output reg   [31:0] instr,        // Fetched instruction
    output reg          imem_ready    // 1 = data ready, 0 = busy
);

  // Memory array (1KB = 256 x 32-bit words)
  reg [31:0] mem [0:255];

  // Internal address register (word-aligned)
  reg [7:0] addr_reg;

  // Initialize memory from a hex file (optional)
  initial begin
    $readmemh("program.hex", mem);
    imem_ready = 1; // Ready at startup
  end

  // Synchronous read with configurable latency
  always @(posedge clk) begin
    if (imem_ready) begin
      // Capture new address and start read
      addr_reg <= addr[31:2]; // Convert byte address to word index
      imem_ready <= 0;        // Signal "busy"
    end else begin
      // Complete read after 1 cycle (modify for longer latency)
      instr <= mem[addr_reg];
      imem_ready <= 1;        // Signal "ready"
    end
  end

endmodule
