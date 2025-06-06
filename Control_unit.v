// Local definitions (normally in Def.v)
// Instruction types
`define R_type        3'b000
`define I_type        3'b001
`define I_type_load   3'b010
`define S_type        3'b011
`define B_type        3'b100
`define U_type_LUI    3'b101
`define J_type        3'b110
`define U_type_AUIPC  3'b111

// ALU operations
`define ADD   4'b0000
`define SUB   4'b0001
`define SLL   4'b0010
`define SLT   4'b0011
`define SLTU  4'b0100
`define XOR   4'b0101
`define SRL   4'b0110
`define SRA   4'b0111
`define OR    4'b1000
`define AND   4'b1001
`define ERR   4'b1111

module control_unit(
    input clk,
    input reset,
    input load_type_in,
    input [6:0] opcode_in,
    input [2:0] funct3_in,
    input funct7_in,
    
    output reg werf_contrl,
    output reg [1:0] wbmux_contol,
    output reg [3:0] aluop,
    output reg [1:0] ir_mux,
    output stall,
    output reg [2:0] op_format_out,
    output bypass_ir1,
    output bypass_ir2,
    output sb_type,
    output out_u_type,
    output reg reg_u_type_lui,
    output ready_in,
    output i_type_load
);

// State definitions
parameter FETCH = 1'b0;
parameter LOAD_STALL = 1'b1;

// Instruction type detection - FIXED SYNTAX
wire r_type = (opcode_in == 7'b0110011);
wire i_type = (opcode_in == 7'b0010011);
assign i_type_load = (opcode_in == 7'b0000011);  // Changed to assign
wire s_type = (opcode_in == 7'b0100011);
wire b_type = (opcode_in == 7'b1100011);
wire i_type_jalr = (opcode_in == 7'b1100111);
wire j_type = (opcode_in == 7'b1101111) || i_type_jalr;  // Changed | to ||
wire u_type_lui = (opcode_in == 7'b0110111);
wire u_type_auipc = (opcode_in == 7'b0010111);

// Control signals
assign bypass_ir2 = r_type || s_type || b_type;  // Changed | to ||
assign out_u_type = u_type_lui || u_type_auipc;  // Changed | to ||
assign bypass_ir1 = ~(j_type || out_u_type);     // Changed | to ||
assign sb_type = b_type || s_type;               // Changed | to ||
assign stall = i_type_load && ~load_type_in;      // Changed & to &&
assign ready_in = i_type_jalr;

// State machine
reg state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= FETCH;
        reg_u_type_lui <= 0;
    end else begin
        state <= next_state;
        reg_u_type_lui <= u_type_lui;
    end
end

// Combinational logic
always @(*) begin
    // Default values
    next_state = FETCH;
    werf_contrl = 1'b0;
    wbmux_contol = 2'b00;
    aluop = `ADD;
    ir_mux = 2'b00;
    op_format_out = 3'b000;
    
    case (state)
        FETCH: begin
            // Determine operation format
            case (1'b1) // synthesis parallel_case
                u_type_auipc: op_format_out = `U_type_AUIPC;
                b_type:       op_format_out = `B_type;
                j_type:       op_format_out = `J_type;
                u_type_lui:   op_format_out = `U_type_LUI;
                r_type:      op_format_out = `R_type;
                s_type:       op_format_out = `S_type;
                i_type:      op_format_out = `I_type;
                i_type_load:  op_format_out = `I_type_load;
                default:      op_format_out = 3'b000;
            endcase
            
            // ALU operation
            if (op_format_out == `R_type) begin
                case (funct3_in)
                    3'b000: aluop = funct7_in ? `SUB : `ADD;
                    3'b001: aluop = `SLL;
                    3'b010: aluop = `SLT;
                    3'b011: aluop = `SLTU;
                    3'b100: aluop = `XOR;
                    3'b101: aluop = funct7_in ? `SRA : `SRL;
                    3'b110: aluop = `OR;
                    3'b111: aluop = `AND;
                    default: aluop = `ERR;
                endcase
            end
            else if (op_format_out == `I_type) begin
                case (funct3_in)
                    3'b000: aluop = `ADD;
                    3'b001: aluop = `SLL;
                    3'b010: aluop = `SLT;
                    3'b011: aluop = `SLTU;
                    3'b100: aluop = `XOR;
                    3'b101: aluop = funct7_in ? `SRA : `SRL;
                    3'b110: aluop = `OR;
                    3'b111: aluop = `AND;
                    default: aluop = `ERR;
                endcase
            end
            else begin
                aluop = `ADD; // Default for other instructions
            end
            
            // Write enable and WB mux
            werf_contrl = ~op_format_out[1] | op_format_out[0];
            
            case (op_format_out)
                `R_type, `I_type: wbmux_contol = 2'b00; // WB_ALU
                `I_type_load:     wbmux_contol = 2'b01; // WB_MEM
                `J_type:         wbmux_contol = 2'b10; // WB_PC
                default:         wbmux_contol = 2'b00;
            endcase
            
            // IR mux control
            ir_mux = {2{(~op_format_out[0] & ~op_format_out[2]) | (~op_format_out[2] & ~op_format_out[1])}};
            
            // Special case for JALR
            if (i_type_jalr) begin
                op_format_out = `I_type;
            end
            
            next_state = (i_type_load && ~load_type_in) ? LOAD_STALL : FETCH;
        end
        
        LOAD_STALL: begin
            next_state = load_type_in ? LOAD_STALL : FETCH;
        end
    endcase
end

endmodule
