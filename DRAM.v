module dram_controller #(
    parameter ADDR_WIDTH = 32,    // CPU address width
    parameter DATA_WIDTH = 32,    // Data bus width
    parameter ROW_WIDTH = 13,     // DRAM row address
    parameter COL_WIDTH = 10      // DRAM column address
)(
    input clk,
    input resetn,
    
    // CPU Interface
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] wdata,
    input we,
    input re,
    output reg [DATA_WIDTH-1:0] rdata,
    output reg ready,
    
    // DRAM Physical Interface
    output reg ras_n,        // Row Address Strobe
    output reg cas_n,        // Column Address Strobe
    output reg we_n,         // Write Enable
    output reg cs_n,         // Chip Select
    inout [DATA_WIDTH-1:0] dq, // Data bus
    output [ROW_WIDTH-1:0] row_addr,
    output [COL_WIDTH-1:0] col_addr
);

    // DRAM Timing Parameters (in clock cycles)
    parameter tRCD = 2;      // RAS to CAS delay
    parameter tCAS = 2;      // CAS latency
    parameter tRP = 2;       // Precharge to RAS
    parameter tREF = 64;     // Refresh interval

    // State Machine
    parameter [2:0]  INIT = 0,
                    IDLE = 1,
                    ACTIVE = 2,
                    READ = 3,
                    WRITE = 4,
                    PRECHARGE = 5,
                    REFRESH = 6;

    reg [2:0] state;
    reg [2:0] timer;
    reg [15:0] refresh_counter;
    
    // Address decoding
    wire [ROW_WIDTH-1:0] current_row = addr[ADDR_WIDTH-1:COL_WIDTH];
    wire [COL_WIDTH-1:0] current_col = addr[COL_WIDTH-1:0];
    
    // Bank control
    reg [ROW_WIDTH-1:0] open_row;
    reg row_open;
    
    // Data bus control
    reg [DATA_WIDTH-1:0] data_out;
    assign dq = (we_n) ? data_out : {DATA_WIDTH{1'bz}};

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= INIT;
            ras_n <= 1;
            cas_n <= 1;
            we_n <= 1;
            cs_n <= 1;
            ready <= 0;
            refresh_counter <= 0;
            row_open <= 0;
        end else begin
            case(state)
                INIT: begin
                    // Initialize DRAM
                    cs_n <= 0;
                    ras_n <= 1;
                    cas_n <= 1;
                    we_n <= 1;
                    timer <= tRP;
                    state <= PRECHARGE;
                end
                
                PRECHARGE: begin
                    ras_n <= 0;
                    we_n <= 0;
                    if (timer == 0) begin
                        ras_n <= 1;
                        we_n <= 1;
                        state <= IDLE;
                    end else timer <= timer - 1;
                end
                
                IDLE: begin
                    ready <= 0;
                    refresh_counter <= refresh_counter + 1;
                    
                    if (refresh_counter >= tREF) begin
                        // Refresh cycle
                        state <= REFRESH;
                        ras_n <= 0;
                        cas_n <= 0;
                        timer <= tRP;
                        refresh_counter <= 0;
                    end else if (re || we) begin
                        if (row_open && (current_row != open_row)) begin
                            // Close existing row
                            state <= PRECHARGE;
                            timer <= tRP;
                        end else begin
                            // Activate row
                            state <= ACTIVE;
                            ras_n <= 0;
                            timer <= tRCD;
                            open_row <= current_row;
                            row_open <= 1;
                        end
                    end
                end
                
                ACTIVE: begin
                    if (timer == 0) begin
                        ras_n <= 1;
                        if (we) state <= WRITE;
                        else state <= READ;
                        cas_n <= 0;
                        we_n <= we ? 0 : 1;
                        timer <= tCAS;
                    end else timer <= timer - 1;
                end
                
                READ: begin
                    if (timer == 0) begin
                        rdata <= dq;
                        ready <= 1;
                        cas_n <= 1;
                        state <= IDLE;
                    end else timer <= timer - 1;
                end
                
                WRITE: begin
                    if (timer == 0) begin
                        ready <= 1;
                        cas_n <= 1;
                        we_n <= 1;
                        state <= IDLE;
                    end else timer <= timer - 1;
                end
                
                REFRESH: begin
                    if (timer == 0) begin
                        ras_n <= 1;
                        cas_n <= 1;
                        state <= IDLE;
                    end else timer <= timer - 1;
                end
            endcase
        end
    end

    assign row_addr = (state == ACTIVE) ? current_row : open_row;
    assign col_addr = current_col;

endmodule
