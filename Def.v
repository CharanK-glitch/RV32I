// Instruction opcodes (7-bit)
`define OPCODE_LOAD     7'b0000011
`define OPCODE_STORE    7'b0100011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JALR     7'b1100111
`define OPCODE_JAL      7'b1101111
`define OPCODE_OP_IMM   7'b0010011
`define OPCODE_OP       7'b0110011
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111

// Immediate types (for imm_mux in imm_gen)
`define I_type          3'b000
`define I_type_load     3'b001
`define S_type          3'b010
`define B_type          3'b011
`define J_type          3'b100
`define U_type_LUI      3'b101
`define U_type_AUIPC    3'b110

// ALU operations
`define ALU_ADD         4'b0000
`define ALU_SUB         4'b0001
`define ALU_SLL         4'b0010
`define ALU_SLT         4'b0011
`define ALU_SLTU        4'b0100
`define ALU_XOR         4'b0101
`define ALU_SRL         4'b0110
`define ALU_SRA         4'b0111
`define ALU_OR          4'b1000
`define ALU_AND         4'b1001

// Branch types
`define BRANCH_EQ       3'b000
`define BRANCH_NE       3'b001
`define BRANCH_LT       3'b100
`define BRANCH_GE       3'b101
`define BRANCH_LTU      3'b110
`define BRANCH_GEU      3'b111

// Control signals
`define MEM_READ        1'b1
`define MEM_WRITE       1'b1
`define REG_WRITE       1'b1
