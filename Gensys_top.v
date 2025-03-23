module genesys2_top(
    input clk100mhz,
    input [7:0] sw,
    output [7:0] led,
    output uart_tx,
    input uart_rx
);

    // Clock generation
    wire clk_core;
    clk_wiz_0 clk_gen(
        .clk_in1(clk100mhz),
        .clk_out1(clk_core) // 50MHz
    );

    // RISC-V Core
    riscv_soc soc(
        .clk(clk_core),
        .resetn(~sw[0]),
        .gpio_out({led}),
        .gpio_in({sw}),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx)
    );

endmodule
