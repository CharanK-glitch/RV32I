module riscv_soc (
    input clk,
    input resetn,
    // GPIO
    output [31:0] gpio_out,
    input [31:0] gpio_in,
    // UART
    output uart_tx,
    input uart_rx,
    // External Memory Interface
    output [31:0] ext_mem_addr,
    output [31:0] ext_mem_wdata,
    output ext_mem_we,
    output ext_mem_re,
    input [31:0] ext_mem_rdata,
    input ext_mem_ready
);

    // Core Interface
    wire [31:0] pc, instr, mem_addr, mem_wdata, mem_rdata;
    wire mem_we, mem_re, mem_ready;
    wire stall;

    // Interrupt Signals
    wire timer_irq, uart_irq;
    wire [4:0] plic_irq_id;
    wire plic_irq;

    // System Bus
    wire [31:0] bus_addr, bus_wdata, bus_rdata;
    wire bus_we, bus_re, bus_ready;
    
    // Instantiate RISC-V Core
    rv32i_core core (
        .clk(clk),
        .resetn(resetn),
        .stall(stall),
        .pc(pc),
        .instr(instr),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_ready(mem_ready),
        .irq(plic_irq),
        .irq_id(plic_irq_id)
    );

    // Memory System
    mem_system memory_subsystem (
        .clk(clk),
        .resetn(resetn),
        .core_addr(mem_addr),
        .core_wdata(mem_wdata),
        .core_we(mem_we),
        .core_re(mem_re),
        .core_rdata(mem_rdata),
        .core_ready(mem_ready),
        .ext_mem_addr(ext_mem_addr),
        .ext_mem_wdata(ext_mem_wdata),
        .ext_mem_we(ext_mem_we),
        .ext_mem_re(ext_mem_re),
        .ext_mem_rdata(ext_mem_rdata),
        .ext_mem_ready(ext_mem_ready)
    );

    // Peripherals
    gpio gpio0 (
        .clk(clk),
        .resetn(resetn),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .we(bus_we),
        .rdata(bus_rdata),
        .gpio_out(gpio_out),
        .gpio_in(gpio_in)
    );

    timer timer0 (
        .clk(clk),
        .resetn(resetn),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .we(bus_we),
        .rdata(bus_rdata),
        .irq(timer_irq)
    );

    uart uart0 (
        .clk(clk),
        .resetn(resetn),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .we(bus_we),
        .rdata(bus_rdata),
        .tx(uart_tx),
        .rx(uart_rx),
        .irq(uart_irq)
    );

    // PLIC Interrupt Controller
    plic plic0 (
        .clk(clk),
        .resetn(resetn),
        .irq_sources({27'b0, uart_irq, timer_irq}),
        .irq_id(plic_irq_id),
        .irq(plic_irq)
    );

    // Stall Unit
    stall_unit stall_ctl (
        .imem_ready(mem_ready),
        .dmem_ready(mem_ready),
        .stall(stall)
    );

endmodule
