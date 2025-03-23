module riscv_soc (
    input         clk,
    input         reset,
    // GPIO Pins
    output [31:0] gpio_out,
    input  [31:0] gpio_in,
    // UART (optional)
    output        uart_tx,
    input         uart_rx
);

  // CPU Interface
  wire [31:0] cpu_addr, cpu_wdata, cpu_rdata;
  wire cpu_we, cpu_re, cpu_ready;

  // Memory Interface
  wire [31:0] mem_addr, mem_wdata, mem_rdata;
  wire mem_we, mem_re;

  // Timer Interface
  wire [31:0] timer_addr, timer_wdata, timer_rdata;
  wire timer_we, timer_irq;

  // GPIO Interface
  wire [31:0] gpio_addr, gpio_wdata, gpio_rdata;
  wire gpio_we;

  // Instantiate RISC-V core
  rv32i_core core (
    .clk(clk),
    .reset(reset),
    .mem_addr(cpu_addr),
    .mem_wdata(cpu_wdata),
    .mem_rdata(cpu_rdata),
    .mem_we(cpu_we),
    .mem_re(cpu_re),
    .mem_ready(cpu_ready),
    .irq(timer_irq)
  );

  // System bus
  system_bus bus (
    .clk(clk),
    .reset(reset),
    // CPU
    .cpu_addr(cpu_addr),
    .cpu_wdata(cpu_wdata),
    .cpu_we(cpu_we),
    .cpu_re(cpu_re),
    .cpu_rdata(cpu_rdata),
    .cpu_ready(cpu_ready),
    // Memory
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_we(mem_we),
    .mem_re(mem_re),
    .mem_rdata(mem_rdata),
    .mem_ready(1'b1), // Assume memory is always ready
    // Timer
    .timer_addr(timer_addr),
    .timer_wdata(timer_wdata),
    .timer_we(timer_we),
    .timer_rdata(timer_rdata),
    // GPIO
    .gpio_addr(gpio_addr),
    .gpio_wdata(gpio_wdata),
    .gpio_we(gpio_we),
    .gpio_rdata(gpio_rdata)
  );

  // Instruction/Data Memory (BRAM)
  bram memory (
    .clk(clk),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .we(mem_we),
    .rdata(mem_rdata)
  );

  // Timer peripheral
  timer timer0 (
    .clk(clk),
    .reset(reset),
    .addr(timer_addr),
    .wdata(timer_wdata),
    .we(timer_we),
    .rdata(timer_rdata),
    .timer_irq(timer_irq)
  );

  // GPIO peripheral
  gpio gpio0 (
    .clk(clk),
    .reset(reset),
    .addr(gpio_addr),
    .wdata(gpio_wdata),
    .we(gpio_we),
    .rdata(gpio_rdata),
    .gpio_out(gpio_out),
    .gpio_in(gpio_in)
  );

endmodule
