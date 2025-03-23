module axi_manager #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input resetn,

    // RISC-V Core Interface
    input [ADDR_WIDTH-1:0]  mem_addr,
    input [DATA_WIDTH-1:0]  mem_wdata,
    input                   mem_we,
    input                   mem_re,
    output reg [DATA_WIDTH-1:0] mem_rdata,
    output reg                  mem_ready,

    // AXI4-Lite Interface
    output reg [ADDR_WIDTH-1:0] axi_awaddr,
    output reg                  axi_awvalid,
    input                       axi_awready,

    output reg [DATA_WIDTH-1:0] axi_wdata,
    output reg                  axi_wvalid,
    input                       axi_wready,

    input [1:0]             axi_bresp,
    input                   axi_bvalid,
    output reg              axi_bready,

    output reg [ADDR_WIDTH-1:0] axi_araddr,
    output reg                  axi_arvalid,
    input                       axi_arready,

    input [DATA_WIDTH-1:0]  axi_rdata,
    input [1:0]             axi_rresp,
    input                   axi_rvalid,
    output reg              axi_rready
);

    // State Definitions (Fixed for Verilog)
    parameter IDLE        = 3'b000,
              WRITE_ADDR  = 3'b001,
              WRITE_DATA  = 3'b010,
              READ_ADDR   = 3'b011,
              READ_DATA   = 3'b100;

    reg [2:0] state;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            axi_awvalid <= 0;
            axi_wvalid <= 0;
            axi_bready <= 0;
            axi_arvalid <= 0;
            axi_rready <= 0;
            mem_ready <= 0;
        end else begin
            case(state)
                IDLE: begin
                    mem_ready <= 0;
                    if (mem_we) begin
                        axi_awaddr <= mem_addr;
                        axi_awvalid <= 1;
                        axi_wdata <= mem_wdata;
                        axi_wvalid <= 1;
                        state <= WRITE_ADDR;
                    end else if (mem_re) begin
                        axi_araddr <= mem_addr;
                        axi_arvalid <= 1;
                        state <= READ_ADDR;
                    end
                end

                WRITE_ADDR: begin
                    if (axi_awready) begin
                        axi_awvalid <= 0;
                        state <= WRITE_DATA;
                    end
                end

                WRITE_DATA: begin
                    if (axi_wready) begin
                        axi_wvalid <= 0;
                        axi_bready <= 1;
                        state <= IDLE;
                        mem_ready <= 1;
                    end
                end

                READ_ADDR: begin
                    if (axi_arready) begin
                        axi_arvalid <= 0;
                        state <= READ_DATA;
                    end
                end

                READ_DATA: begin
                    if (axi_rvalid) begin
                        mem_rdata <= axi_rdata;
                        axi_rready <= 1;
                        state <= IDLE;
                        mem_ready <= 1;
                    end
                end
            endcase
        end
    end

endmodule
