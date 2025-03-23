module apb3_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Clock and Reset
    input                       PCLK,
    input                       PRESETn,
    
    // Master Interface
    input                       start,
    input      [ADDR_WIDTH-1:0] PADDR,
    input                       PWRITE,
    input      [DATA_WIDTH-1:0] PWDATA,
    output reg [DATA_WIDTH-1:0] PRDATA,
    output reg                  PREADY,
    output reg                  PSLVERR,
    
    // Slave Interface
    output reg                  PSEL,
    output reg                  PENABLE,
    output reg [ADDR_WIDTH-1:0] PADDR_out,
    output reg                  PWRITE_out,
    output reg [DATA_WIDTH-1:0] PWDATA_out,
    input      [DATA_WIDTH-1:0] PRDATA_in,
    input                       PREADY_in,
    input                       PSLVERR_in
);

    // State Definitions (Verilog-compatible)
    parameter IDLE  = 2'b00,
              SETUP = 2'b01,
              ACCESS = 2'b10;
    
    reg [1:0] state;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            PADDR_out <= 0;
            PWDATA_out <= 0;
            PRDATA <= 0;
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if (start) begin
                        PSEL <= 1'b1;
                        PENABLE <= 1'b0;
                        PADDR_out <= PADDR;
                        PWRITE_out <= PWRITE;
                        PWDATA_out <= PWDATA;
                        state <= SETUP;
                    end
                end
                
                SETUP: begin
                    PENABLE <= 1'b1;
                    state <= ACCESS;
                end
                
                ACCESS: begin
                    if (PREADY_in) begin
                        PSEL <= 1'b0;
                        PENABLE <= 1'b0;
                        PRDATA <= PRDATA_in;
                        PSLVERR <= PSLVERR_in;
                        PREADY <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
