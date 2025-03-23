module system_bus (
    input         clk,
    input         reset,
    // CPU Interface
    input  [31:0] cpu_addr,
    input  [31:0] cpu_wdata,
    input         cpu_we,
    input         cpu_re,
    output [31:0] cpu_rdata,
    output        cpu_ready,
    // Memory Interface
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output        mem_we,
    output        mem_re,
    input  [31:0] mem_rdata,
    input         mem_ready,
    // Timer Interface
    output [31:0] timer_addr,
    output [31:0] timer_wdata,
    output        timer_we,
    input  [31:0] timer_rdata,
    // GPIO Interface
    output [31:0] gpio_addr,
    output [31:0] gpio_wdata,
    output        gpio_we,
    input  [31:0] gpio_rdata,
    // UART Interface (ADD THIS)
    output [31:0] uart_addr,
    output [31:0] uart_wdata,
    output        uart_we,
    input  [31:0] uart_rdata,
    // PLIC Interface (ADD THIS)
    output [31:0] plic_addr,
    output [31:0] plic_wdata,
    output        plic_we,
    input  [31:0] plic_rdata
);
  // ... Address decoding and logic ...
endmodule
