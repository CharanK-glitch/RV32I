module riscv_soc (
    input clk,
    input resetn,
    // GPIO
    output [31:0] gpio_out,
    input [31:0] gpio_in,
    // UART
    output uart_tx,
    input uart_rx,
    // AXI4-Lite Interface
    // Write Address Channel
    output [31:0] axi_awaddr,
    output axi_awvalid,
    input axi_awready,
    // Write Data Channel
    output [31:0] axi_wdata,
    output axi_wvalid,
    input axi_wready,
    // Write Response Channel
    input [1:0] axi_bresp,
    input axi_bvalid,
    output axi_bready,
    // Read Address Channel
    output [31:0] axi_araddr,
    output axi_arvalid,
    input axi_arready,
    // Read Data Channel
    input [31:0] axi_rdata,
    input [1:0] axi_rresp,
    input axi_rvalid,
    output axi_rready
);

    // Core Interface
    wire [31:0] pc, instr, mem_addr, mem_wdata, mem_rdata;
    wire mem_we, mem_re, mem_ready;
    wire stall;

    // System Bus
    wire [31:0] bus_addr, bus_wdata, bus_rdata;
    wire bus_we, bus_re, bus_ready;

    // Address Decoder Signals
    wire mem_select;  // 0=Peripheral, 1=AXI Memory
    wire [31:0] axi_mem_rdata;
    wire axi_mem_ready;

    // Interrupt Signals
    wire timer_irq, uart_irq;
    wire [4:0] plic_irq_id;
    wire plic_irq;

    // Address Decoder
    assign mem_select = (mem_addr >= 32'h4000_0000); // Memory-mapped above 1GB
    
    // Core Instantiation
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

    // AXI4-Lite Manager for External Memory
    axi_lite_manager axi_mgr (
        .clk(clk),
        .resetn(resetn),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .we(mem_we & mem_select),
        .re(mem_re & mem_select),
        .rdata(axi_mem_rdata),
        .ready(axi_mem_ready),
        // AXI Interface
        .AWADDR(axi_awaddr),
        .AWVALID(axi_awvalid),
        .AWREADY(axi_awready),
        .WDATA(axi_wdata),
        .WVALID(axi_wvalid),
        .WREADY(axi_wready),
        .BRESP(axi_bresp),
        .BVALID(axi_bvalid),
        .BREADY(axi_bready),
        .ARADDR(axi_araddr),
        .ARVALID(axi_arvalid),
        .ARREADY(axi_arready),
        .RDATA(axi_rdata),
        .RRESP(axi_rresp),
        .RVALID(axi_rvalid),
        .RREADY(axi_rready)
    );

    // System Bus Controller for Peripherals
    system_bus_ctrl bus_ctrl (
        .clk(clk),
        .resetn(resetn),
        .cpu_addr(mem_addr),
        .cpu_wdata(mem_wdata),
        .cpu_we(mem_we & ~mem_select),
        .cpu_re(mem_re & ~mem_select),
        .cpu_rdata(bus_rdata),
        .cpu_ready(bus_ready),
        // Bus Interface
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_we(bus_we),
        .bus_re(bus_re)
    );

    // Peripheral Instantiation
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

    // Stall Control
    stall_unit stall_ctl (
        .imem_ready(mem_ready),
        .dmem_ready(mem_ready),
        .stall(stall)
    );

    // Memory Response Mux
    assign mem_rdata = mem_select ? axi_mem_rdata : bus_rdata;
    assign mem_ready = mem_select ? axi_mem_ready : bus_ready;

endmodule

// System Bus Controller
module system_bus_ctrl (
    input clk,
    input resetn,
    // CPU Interface
    input [31:0] cpu_addr,
    input [31:0] cpu_wdata,
    input cpu_we,
    input cpu_re,
    output [31:0] cpu_rdata,
    output cpu_ready,
    // Bus Interface
    output [31:0] bus_addr,
    output [31:0] bus_wdata,
    output bus_we,
    output bus_re
);

    reg [31:0] rdata_reg;
    reg ready_reg;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            ready_reg <= 0;
            rdata_reg <= 0;
        end else begin
            ready_reg <= cpu_we || cpu_re;
            rdata_reg <= 32'h0; // Actual peripheral would drive this
        end
    end

    assign bus_addr = cpu_addr;
    assign bus_wdata = cpu_wdata;
    assign bus_we = cpu_we;
    assign bus_re = cpu_re;
    assign cpu_rdata = rdata_reg;
    assign cpu_ready = ready_reg;

endmodule
