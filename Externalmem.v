module external_mem_interface #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Memory Controller Interface
    input                       clk,
    input                       rst_n,
    input                       cs,       // Chip select
    input                       we,       // Write enable
    input                       oe,       // Output enable (read)
    input      [ADDR_WIDTH-1:0] addr,
    input      [DATA_WIDTH-1:0] wdata,
    output reg [DATA_WIDTH-1:0] rdata,
    output reg                  ready,    // Memory ready
    // Physical Memory Pins
    output                      mem_clk,
    output reg                  mem_cs_n,
    output reg                  mem_we_n,
    output reg                  mem_oe_n,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    inout      [DATA_WIDTH-1:0] mem_data
);

    // Tri-state buffer for data bus
    reg [DATA_WIDTH-1:0] data_out;
    assign mem_data = oe ? data_out : {DATA_WIDTH{1'bz}};

    // State definitions (Verilog-compatible)
    parameter IDLE  = 2'b00,
              READ  = 2'b01,
              WRITE = 2'b10,
              WAIT  = 2'b11;

    reg [1:0] state;

    // Timing counter
    reg [3:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            ready <= 0;
            mem_cs_n <= 1;
            mem_we_n <= 1;
            mem_oe_n <= 1;
            counter <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if (cs) begin
                        mem_cs_n <= 0;
                        mem_addr <= addr;
                        if (we) begin
                            mem_we_n <= 0;
                            data_out <= wdata;
                            state <= WRITE;
                        end else begin
                            mem_oe_n <= 0;
                            state <= READ;
                        end
                        counter <= 2; // Adjust based on T_ACC/T_CLK
                    end
                end

                READ: begin
                    if (counter == 0) begin
                        rdata <= mem_data;
                        ready <= 1;
                        mem_oe_n <= 1;
                        mem_cs_n <= 1;
                        state <= IDLE;
                    end else counter <= counter - 1;
                end

                WRITE: begin
                    if (counter == 0) begin
                        ready <= 1;
                        mem_we_n <= 1;
                        mem_cs_n <= 1;
                        state <= IDLE;
                    end else counter <= counter - 1;
                end
            endcase
        end
    end

endmodule
