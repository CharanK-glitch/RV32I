module data_memory (
    input               clk,          // Clock
    input        [31:0] addr,         // Byte address (word-aligned for RV32I)
    input        [31:0] write_data,   // Data to write (for stores)
    input               mem_read,     // Read enable (for loads)
    input               mem_write,    // Write enable (for stores)
    output reg   [31:0] read_data,    // Read data output
    output reg          mem_ready     // 1 = ready, 0 = busy
);

  // Memory array (1KB = 256 x 32-bit words)
  reg [31:0] mem [0:255];

  // Internal address register (word-aligned)
  reg [7:0] addr_reg;

  // Optional initialization (e.g., for testing)
  initial begin
    // Initialize all memory to zero
    for (integer i = 0; i < 256; i++) begin
      mem[i] = 32'h0;
    end
    mem_ready = 1; // Ready at startup
  end

  // Memory operations
  always @(posedge clk) begin
    if (mem_ready) begin
      // Handle new request
      if (mem_read) begin
        // Capture address and start read
        addr_reg  <= addr[31:2]; // Convert byte address to word index
        mem_ready <= 0;          // Signal "busy"
      end else if (mem_write) begin
        // Write immediately (no delay)
        mem[addr[31:2]] <= write_data;
      end
    end else begin
      // Complete read after 1 cycle
      read_data <= mem[addr_reg];
      mem_ready <= 1; // Signal "ready"
    end
  end

endmodule
