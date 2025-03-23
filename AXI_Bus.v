module system_bus (
    input         clk,          // System clock
    input         reset,        // Global reset
    // CPU Interface (Master)
    input  [31:0] cpu_addr,     // Address from CPU
    input  [31:0] cpu_wdata,    // Write data from CPU
    input         cpu_we,       // Write enable
    input         cpu_re,       // Read enable
    output [31:0] cpu_rdata,    // Read data to CPU
    output        cpu_ready,    // Transfer complete
    // Peripheral Interfaces (Slaves)
    output [31:0] mem_addr,     // Memory address
    output [31:0] mem_wdata,    // Memory write data
    output        mem_we,       // Memory write enable
    output        mem_re,       // Memory read enable
    input  [31:0] mem_rdata,    // Memory read data
    input         mem_ready,    // Memory ready
    output [31:0] timer_addr,   // Timer address
    output [31:0] timer_wdata,  // Timer write data
    output        timer_we,     // Timer write enable
    input  [31:0] timer_rdata,  // Timer read data
    output [31:0] gpio_addr,    // GPIO address
    output [31:0] gpio_wdata,   // GPIO write data
    output        gpio_we,      // GPIO write enable
    input  [31:0] gpio_rdata    // GPIO read data
);

  // Address Decoding (Adjust ranges as needed)
  wire sel_mem  = (cpu_addr[31:24] == 8'h00);       // 0x0000_0000 - 0x00FF_FFFF
  wire sel_timer= (cpu_addr[31:24] == 8'h10);       // 0x1000_0000 - 0x10FF_FFFF
  wire sel_gpio = (cpu_addr[31:24] == 8'h20);       // 0x2000_0000 - 0x20FF_FFFF

  // Mux read data from selected peripheral
  assign cpu_rdata = sel_mem   ? mem_rdata :
                     sel_timer ? timer_rdata :
                     sel_gpio  ? gpio_rdata :
                     32'h0;

  // Propagate signals to peripherals
  assign mem_addr   = cpu_addr;
  assign mem_wdata  = cpu_wdata;
  assign mem_we     = sel_mem & cpu_we;
  assign mem_re     = sel_mem & cpu_re;

  assign timer_addr  = cpu_addr;
  assign timer_wdata = cpu_wdata;
  assign timer_we    = sel_timer & cpu_we;

  assign gpio_addr   = cpu_addr;
  assign gpio_wdata  = cpu_wdata;
  assign gpio_we     = sel_gpio & cpu_we;

  // Assume peripherals are always ready (modify if needed)
  assign cpu_ready = sel_mem ? mem_ready : 1'b1;

endmodule
