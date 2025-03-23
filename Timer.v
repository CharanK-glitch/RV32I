module timer (
    input         clk,
    input         reset,
    // Bus Interface
    input  [31:0] addr,
    input  [31:0] wdata,
    input         we,
    output [31:0] rdata,
    // Interrupt
    output        timer_irq
);

  // Registers (word-addressable)
  reg [31:0] counter;    // 0x00: Current count (read-only)
  reg [31:0] compare;    // 0x04: Compare value
  reg        enable;     // 0x08: Timer enable (bit 0)

  // Internal signals
  wire match = (counter == compare);

  // Read logic
  assign rdata = (addr[3:0] == 4'h0) ? counter :
                 (addr[3:0] == 4'h4) ? compare :
                 (addr[3:0] == 4'h8) ? {31'h0, enable} :
                 32'h0;

  // Write logic
  always @(posedge clk) begin
    if (reset) begin
      counter <= 32'h0;
      compare <= 32'hFFFF_FFFF;
      enable  <= 1'b0;
    end else begin
      if (we) begin
        case (addr[3:0])
          4'h4: compare <= wdata;
          4'h8: enable  <= wdata[0];
        endcase
      end
      if (enable) begin
        counter <= counter + 1;
      end
    end
  end

  // Interrupt on match
  assign timer_irq = match & enable;

endmodule
