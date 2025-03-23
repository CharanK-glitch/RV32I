module tb_riscv_soc;
    reg clk = 0;
    reg resetn = 0;
    wire [31:0] gpio_out;
    wire uart_tx;

    // Instantiate SoC
    riscv_soc soc (
        .clk(clk),
        .resetn(resetn),
        .gpio_out(gpio_out),
        .gpio_in(32'h0),
        .uart_tx(uart_tx),
        .uart_rx(1'b1)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Load test program
    initial begin
        $readmemh("test_program.hex", soc.memory_subsystem.rom.mem);
    end

    // Test sequence
    initial begin
        // Reset
        resetn = 0;
        #100 resetn = 1;

        // Monitor GPIO changes
        $display("GPIO Output: %h", gpio_out);
        
        // Run for 1000 cycles
        #10000 $display("Test Complete");
        $finish;
    end

    // UART monitor
    always @(negedge uart_tx) begin
        $display("[UART] TX: %c", soc.uart0.tx_data);
    end

endmodule
