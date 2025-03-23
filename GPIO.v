module gpio (
    input         clk,
    input         reset,
    // Bus Interface
    input  [31:0] addr,
    input  [31:0] wdata,
    input         we,
    output [31:0] rdata,
    // GPIO Pins
    output [31:0] gpio_out,
    input  [31:0] gpio_in
);

  // Registers (word-addressable)
  reg [31:0] dir_reg;   // 0x00: Direction (0=input, 1=output)
  reg [31:0] out_reg;   // 0x04: Output data
  reg [31:0] in_reg;    // 0x08: Input data (read-only)

  // Read logic
  assign rdata = (addr[3:0] == 4'h0) ? dir_reg :
                 (addr[3:0] == 4'h4) ? out_reg :
                 (addr[3:0] == 4'h8) ? in_reg  :
                 32'h0;

  // Write logic
  always @(posedge clk) begin
    if (reset) begin
      dir_reg <= 32'h0;
      out_reg <= 32'h0;
    end else if (we) begin
      case (addr[3:0])
        4'h0: dir_reg <= wdata;
        4'h4: out_reg <= wdata;
      endcase
    end
  end

  // Sync input pins
  always @(posedge clk) begin
    in_reg <= gpio_in;
  end

  // Drive output pins
  assign gpio_out = out_reg;

endmodule
