module riscv_soc (
    input         clk,
    input         reset,
    // GPIO Pins
    output [31:0] gpio_out,
    input  [31:0] gpio_in,
    // UART
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
  wire timer_we;
  wire timer_irq;

  // GPIO Interface
  wire [31:0] gpio_addr, gpio_wdata, gpio_rdata;
  wire gpio_we;

  // UART Interface
  wire [31:0] uart_addr, uart_wdata, uart_rdata;
  wire uart_we;
  wire uart_irq;

  // PLIC Interface
  wire [31:0] plic_addr, plic_wdata, plic_rdata;
  wire plic_we;
  wire plic_irq;
  wire [4:0]  plic_irq_id;

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
    .irq(plic_irq),          // Connect PLIC interrupt
    .irq_id(plic_irq_id)     // Optional: Interrupt ID for advanced cores
  );

  // System Bus
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
    .mem_ready(1'b1),        // Assume memory is always ready
    // Timer
    .timer_addr(timer_addr),
    .timer_wdata(timer_wdata),
    .timer_we(timer_we),
    .timer_rdata(timer_rdata),
    // GPIO
    .gpio_addr(gpio_addr),
    .gpio_wdata(gpio_wdata),
    .gpio_we(gpio_we),
    .gpio_rdata(gpio_rdata),
    // UART
    .uart_addr(uart_addr),
    .uart_wdata(uart_wdata),
    .uart_we(uart_we),
    .uart_rdata(uart_rdata),
    // PLIC
    .plic_addr(plic_addr),
    .plic_wdata(plic_wdata),
    .plic_we(plic_we),
    .plic_rdata(plic_rdata)
  );

  // Instruction/Data Memory (BRAM)
  bram memory (
    .clk(clk),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .we(mem_we),
    .rdata(mem_rdata)
  );

  // Timer Peripheral
  timer timer0 (
    .clk(clk),
    .reset(reset),
    .addr(timer_addr),
    .wdata(timer_wdata),
    .we(timer_we),
    .rdata(timer_rdata),
    .timer_irq(timer_irq)
  );

  // GPIO Peripheral
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

  // UART Peripheral
  uart uart0 (
    .clk(clk),
    .reset(reset),
    .addr(uart_addr),
    .wdata(uart_wdata),
    .we(uart_we),
    .rdata(uart_rdata),
    .tx(uart_tx),
    .rx(uart_rx),
    .uart_irq(uart_irq)
  );

  // PLIC (Platform-Level Interrupt Controller)
  plic plic0 (
    .clk(clk),
    .reset(reset),
    .addr(plic_addr),
    .wdata(plic_wdata),
    .we(plic_we),
    .rdata(plic_rdata),
    .irq_sources({29'b0, uart_irq, timer_irq}), // Assign IRQ IDs
    .plic_irq(plic_irq),
    .plic_irq_id(plic_irq_id)
  );

endmodule
