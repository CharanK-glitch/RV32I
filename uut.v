module uart (
    input         clk,
    input         reset,
    // Bus Interface
    input  [31:0] addr,      // Address offset (0x00: Data, 0x04: Control, 0x08: Status)
    input  [31:0] wdata,
    input         we,
    output [31:0] rdata,
    // UART Pins
    output        tx,        // Transmit pin
    input         rx,        // Receive pin
    // Interrupt
    output        uart_irq   // Interrupt (TX empty or RX ready)
);

  // Registers
  reg [7:0]  tx_data;        // Data to transmit (write-only)
  reg [7:0]  rx_data;        // Received data (read-only)
  reg [15:0] baud_div;       // Baud rate divisor (control[15:0])
  reg        tx_enable;      // Transmit enable (control[16])
  reg        rx_enable;      // Receive enable (control[17])
  reg        tx_empty;       // Status[0]
  reg        rx_ready;       // Status[1]
  reg        irq_enable;     // Interrupt enable (control[31])

  // Internal signals
  reg [15:0] tx_counter;     // Baud counter for TX
  reg [15:0] rx_counter;     // Baud counter for RX
  reg [3:0]  tx_state;       // TX state machine
  reg [3:0]  rx_state;       // RX state machine

  // Read logic
  assign rdata = (addr[3:0] == 4'h0) ? {24'b0, rx_data} :
                 (addr[3:0] == 4'h4) ? {baud_div, tx_enable, rx_enable, irq_enable} :
                 (addr[3:0] == 4'h8) ? {30'b0, rx_ready, tx_empty} :
                 32'h0;

  // Interrupt generation
  assign uart_irq = irq_enable & (tx_empty | rx_ready);

  // TX state machine
  always @(posedge clk) begin
    if (reset) begin
      tx_state <= 0;
      tx_empty <= 1;
    end else begin
      case (tx_state)
        0: if (we && addr[3:0] == 4'h0) begin
          tx_data <= wdata[7:0];
          tx_empty <= 0;
          tx_state <= 1;
          tx_counter <= baud_div;
        end
        1: begin
          if (tx_counter == 0) begin
            tx <= 0; // Start bit
            tx_state <= 2;
            tx_counter <= baud_div;
          end else tx_counter <= tx_counter - 1;
        end
        2: begin
          if (tx_counter == 0) begin
            tx <= tx_data[0]; // LSB first
            tx_data <= tx_data >> 1;
            tx_state <= tx_state + 1;
            tx_counter <= baud_div;
          end else tx_counter <= tx_counter - 1;
        end
        // ... Repeat for 8 data bits ...
        10: begin
          if (tx_counter == 0) begin
            tx <= 1; // Stop bit
            tx_state <= 11;
            tx_counter <= baud_div;
          end else tx_counter <= tx_counter - 1;
        end
        11: begin
          if (tx_counter == 0) begin
            tx_empty <= 1;
            tx_state <= 0;
          end else tx_counter <= tx_counter - 1;
        end
      endcase
    end
  end

  // RX state machine (similar logic for sampling rx pin)
  // ...

endmodule
