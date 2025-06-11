module pip_reg4(
    input clk,
    input [4:0] addr_wb_in,
    input werf_enable_in,
    input [31:0] pc_plus_4_in,
    input [31:0] immu_in,
    input [31:0] pc_plus_immu_in,
    input [31:0] read_mem_in,
    input [31:0] alu_result_in,
    input load_in,
    input [1:0] wb_select_in,
    
    output reg [31:0] pc_plus_4_out,
    output reg [31:0] immu_out,
    output reg [31:0] pc_plus_immu_out,
    output reg [31:0] read_mem_out,
    output reg [31:0] alu_result_out,
    output reg load_out,
    output reg [1:0] wb_select_out,
    output reg [4:0] addr_wb_out,
    output reg werf_enable_out,
    
    // Additional output for write data
    output [31:0] write_data
);

    // Pipeline registers (same as your original code)
    always @(posedge clk) begin
        pc_plus_4_out      <= pc_plus_4_in;
        immu_out           <= immu_in;
        pc_plus_immu_out   <= pc_plus_immu_in;
        read_mem_out       <= read_mem_in;
        alu_result_out     <= alu_result_in;
        load_out           <= load_in;
        wb_select_out      <= wb_select_in;
        addr_wb_out        <= addr_wb_in;
        werf_enable_out    <= werf_enable_in;
    end

    // Write Data Selection Unit
    assign write_data = (werf_enable_out) ? 
                       (wb_select_out == 2'b00) ? alu_result_out :  // ALU result
                       (wb_select_out == 2'b01) ? read_mem_out :    // Memory read data
                       (wb_select_out == 2'b10) ? pc_plus_4_out :   // PC+4 (for JAL/JALR)
                       (wb_select_out == 2'b11) ? immu_out :       // Immediate (for LUI/AUIPC)
                       32'b0 :                                     // Default case
                       32'b0;                                      // When not writing

endmodule
