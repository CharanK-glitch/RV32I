module ALU(operand_1, operand_2, aluop, out);  // Fixed module name

input   [31:0]  operand_1, operand_2;
input   [3:0]   aluop;
output reg [31:0] out;

// ALU operation definitions
`define ADD  4'b0000
`define SUB  4'b0001
`define XOR  4'b0010
`define OR   4'b0011
`define AND  4'b0100
`define SLL  4'b0101
`define SRL  4'b0110
`define SRA  4'b0111
`define SLT  4'b1000
`define SLTU 4'b1001

// Internal signals
wire    [31:0]  addr_in, sub_in, xor_in, or_in, and_in, sll_in, srl_in, sra_in;
wire            slt_in, sltu_in;
wire signed [31:0] rs_op1;

assign rs_op1 = operand_1;  // Signed view

assign addr_in = operand_1 + operand_2;
assign sub_in  = operand_1 - operand_2;
assign xor_in  = operand_1 ^ operand_2;
assign or_in   = operand_1 | operand_2;
assign and_in  = operand_1 & operand_2;
assign sll_in  = operand_1 << operand_2[4:0];
assign srl_in  = operand_1 >> operand_2[4:0];
assign sra_in  = operand_1 >>> operand_2[4:0];  // Arithmetic shift

assign slt_in  = (rs_op1 < $signed(operand_2));  // Signed comparison
assign sltu_in = (operand_1 < operand_2);        // Unsigned

// ALU output with default case
always @(*) begin
    case(aluop)
        `ADD:  out = addr_in;
        `SUB:  out = sub_in;
        `XOR:  out = xor_in;
        `OR:   out = or_in;
        `AND:  out = and_in;
        `SLL:  out = sll_in;
        `SRL:  out = srl_in;
        `SRA:  out = sra_in;
        `SLT:  out = {31'b0, slt_in};
        `SLTU: out = {31'b0, sltu_in};
        default: out = 32'h0000_0000;  // Handle undefined aluop
    endcase
end

endmodule
