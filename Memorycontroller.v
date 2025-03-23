module memory_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BURST_LEN  = 4
)(
    input                       clk,
    input                       rst_n,
    // CPU/AXI Interface
    input                       req,       // Request
    input                       we,
    input      [ADDR_WIDTH-1:0] addr,
    input      [DATA_WIDTH-1:0] wdata,
    output reg [DATA_WIDTH-1:0] rdata,
    output reg                  grant,     // Request granted
    // External Memory Interface
    output reg                  cs,
    output reg                  oe,
    output reg                  we_mem,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_wdata,
    input      [DATA_WIDTH-1:0] mem_rdata,
    input                       mem_ready
);

    // State definitions (Verilog-compatible)
    parameter IDLE  = 1'b0,
              BURST = 1'b1;

    reg state;
    reg [2:0] burst_counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            grant <= 0;
            cs <= 0;
            oe <= 0;
            we_mem <= 0;
            burst_counter <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if (req) begin
                        cs <= 1;
                        oe <= !we;
                        we_mem <= we;
                        mem_addr <= addr;
                        mem_wdata <= wdata;
                        burst_counter <= BURST_LEN - 1;
                        state <= BURST;
                        grant <= 1;
                    end
                end

                BURST: begin
                    if (mem_ready) begin
                        if (burst_counter == 0) begin
                            cs <= 0;
                            oe <= 0;
                            we_mem <= 0;
                            grant <= 0;
                            state <= IDLE;
                        end else begin
                            burst_counter <= burst_counter - 1;
                            mem_addr <= mem_addr + 4; // Burst address increment
                        end
                    end
                end
            endcase
        end
    end

    // Capture read data
    always @(posedge clk) begin
        if (state == BURST && oe && mem_ready)
            rdata <= mem_rdata;
    end

endmodule
