module system_main_memory (
    input         clk,          // System clock
    input         reset,        // Global reset
    // Bus Interface
    input  [31:0] addr,         // Word-aligned address
    input  [31:0] wdata,        // Write data
    input         we,           // Write enable
    input         re,           // Read enable
    output [31:0] rdata,        // Read data
    output        mem_ready     // 1 = ready, 0 = busy
);

  // Memory Parameters
  parameter RAM_SIZE   = 1024;  // 1KB RAM (256 x 32-bit words)
  parameter RAM_START  = 32'h0000_0000;
  parameter RAM_END    = 32'h0000_3FFF;
  parameter TIMER_BASE = 32'h1000_0000; // Timer peripheral
  parameter GPIO_BASE  = 32'h2000_0000; // GPIO peripheral
  parameter UART_BASE  = 32'h3000_0000; // UART peripheral
  parameter PLIC_BASE  = 32'h4000_0000; // PLIC

  // Memory Array (RAM)
  reg [31:0] ram [0:RAM_SIZE-1];

  // Initialize RAM from .hex file (instructions/program)
  initial begin
    $readmemh("program.hex", ram);
  end

  // Address Decoding
  wire is_ram    = (addr >= RAM_START) && (addr <= RAM_END);
  wire is_timer  = (addr >= TIMER_BASE) && (addr < TIMER_BASE + 32'h100);
  wire is_gpio   = (addr >= GPIO_BASE)  && (addr < GPIO_BASE + 32'h100);
  wire is_uart   = (addr >= UART_BASE)  && (addr < UART_BASE + 32'h100);
  wire is_plic   = (addr >= PLIC_BASE)  && (addr < PLIC_BASE + 32'h100);

  // Memory Operations
  reg [31:0] rdata_reg;
  reg        ready_reg;

  always @(posedge clk) begin
    if (reset) begin
      rdata_reg <= 0;
      ready_reg <= 1;
    end else begin
      if (re || we) begin
        if (is_ram) begin
          if (we) ram[addr[9:2]] <= wdata; // Word-aligned write (addr[9:2] = word index)
          rdata_reg <= ram[addr[9:2]];      // Read data (1-cycle latency)
        end
        // Handle peripherals (stub for simulation)
        else if (is_timer || is_gpio || is_uart || is_plic) begin
          rdata_reg <= 32'h0; // Peripheral reads handled by dedicated modules
        end
        ready_reg <= 1;
      end
    end
  end

  assign rdata    = rdata_reg;
  assign mem_ready = ready_reg;

endmodule
