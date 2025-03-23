module plic (
    input         clk,
    input         reset,
    // Bus Interface
    input  [31:0] addr,
    input  [31:0] wdata,
    input         we,
    output [31:0] rdata,
    // Interrupt Sources
    input  [31:0] irq_sources, // e.g., [0]=timer, [1]=uart_rx, [2]=uart_tx
    // Interrupt to CPU
    output        plic_irq,
    output [4:0]  plic_irq_id  // ID of highest-priority pending interrupt
);

  // Registers
  reg [31:0] pending;        // Pending interrupts (read-only)
  reg [31:0] enable;         // Interrupt enable (per-source)
  reg [7:0]  priority [31:0]; // Priority for each source (0-255)
  reg [7:0]  threshold;      // Priority threshold (0-255)

  // Effective Priority Calculation
  wire [31:0] effective_prio;
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : gen_effective_prio
      assign effective_prio[i] = (priority[i] > threshold) & pending[i] & enable[i];
    end
  endgenerate

  // Priority Encoder (Find highest-priority interrupt)
  reg [4:0] highest_irq;
  integer j;
  always @(*) begin
    highest_irq = 0;
    for (j = 31; j >= 0; j = j - 1) begin
      if (effective_prio[j]) highest_irq = j;
    end
  end

  // Read Logic
  assign rdata = 
    (addr[7:0] == 8'h00) ? pending :             // 0x00: Pending
    (addr[7:0] == 8'h04) ? enable :              // 0x04: Enable
    (addr[7:0] == 8'h20) ? {24'h0, threshold} :  // 0x20: Threshold
    (addr[7:0] >= 8'h40) ? {24'h0, priority[addr[7:2] - 8'h10]} : // 0x40-0x7C: Priority
    32'h0;

  // Write Logic
  always @(posedge clk) begin
    if (reset) begin
      enable <= 32'h0;
      threshold <= 8'h0;
      for (integer k = 0; k < 32; k = k + 1) priority[k] <= 8'h0;
    end else if (we) begin
      case (addr[7:0])
        8'h04: enable <= wdata;                   // Update enable
        8'h20: threshold <= wdata[7:0];           // Set threshold
        default: if (addr[7:0] >= 8'h40) begin    // Set priority
          priority[addr[7:2] - 8'h10] <= wdata[7:0];
        end
      endcase
    end
  end

  // Update pending interrupts (level-sensitive)
  always @(posedge clk) begin
    pending <= irq_sources;
  end

  // Interrupt Output
  assign plic_irq = (|effective_prio);
  assign plic_irq_id = (|effective_prio) ? highest_irq : 5'h0;

endmodule
