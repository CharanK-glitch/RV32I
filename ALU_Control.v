module alu_control_unit(
    input [6:0] opcode,      // Instruction opcode
    input [2:0] funct3,      // funct3 field
    input [6:0] funct7,      // funct7 field
    output reg [3:0] aluop   // ALU operation code
);

// Instruction opcodes
`define OP_RTYPE 7'b0110011
`define OP_ITYPE 7'b0010011
`define OP_BRANCH 7'b1100011
`define OP_STORE 7'b0100011
`define OP_LOAD 7'b0000011
`define OP_JALR 7'b1100111
`define OP_LUI 7'b0110111

// ALU operations (matches your ALU definitions)
`define ADD 4'b0000
`define SUB 4'b0001
`define XOR 4'b0010
`define OR 4'b0011
`define AND 4'b0100
`define SLL 4'b0101
`define SRL 4'b0110
`define SRA 4'b0111
`define SLT 4'b1000
`define SLTU 4'b1001

always @(*) begin
    case(opcode)
        // R-type instructions
        `OP_RTYPE: begin
            case(funct3)
                3'b000: aluop = funct7[5] ? `SUB : `ADD;  // ADD/SUB
                3'b001: aluop = `SLL;                    // SLL
                3'b010: aluop = `SLT;                     // SLT
                3'b011: aluop = `SLTU;                    // SLTU
                3'b100: aluop = `XOR;                     // XOR
                3'b101: aluop = funct7[5] ? `SRA : `SRL; // SRL/SRA
                3'b110: aluop = `OR;                     // OR
                3'b111: aluop = `AND;                    // AND
                default: aluop = `ADD;
            endcase
        end

        // I-type instructions
        `OP_ITYPE: begin
            case(funct3)
                3'b000: aluop = `ADD;                     // ADDI
                3'b001: aluop = `SLL;                     // SLLI
                3'b010: aluop = `SLT;                     // SLTI
                3'b011: aluop = `SLTU;                    // SLTIU
                3'b100: aluop = `XOR;                     // XORI
                3'b101: aluop = funct7[5] ? `SRA : `SRL; // SRLI/SRAI
                3'b110: aluop = `OR;                      // ORI
                3'b111: aluop = `AND;                     // ANDI
                default: aluop = `ADD;
            endcase
        end

        // Branch instructions
        `OP_BRANCH: begin
            case(funct3)
                3'b000: aluop = `SUB;  // BEQ
                3'b001: aluop = `SUB;  // BNE
                3'b100: aluop = `SLT;  // BLT
                3'b101: aluop = `SLT;  // BGE (inverted in branch unit)
                3'b110: aluop = `SLTU; // BLTU
                3'b111: aluop = `SLTU; // BGEU (inverted in branch unit)
                default: aluop = `SUB;
            endcase
        end

        // Load/Store/JALR/LUI
        `OP_STORE: aluop = `ADD;       // SW/SH/SB (address calculation)
        `OP_LOAD: aluop = `ADD;        // LW/LH/LB (address calculation)
        `OP_JALR: aluop = `ADD;       // JALR (address calculation)
        `OP_LUI: aluop = `ADD;         // LUI (pass-through)

        default: aluop = `ADD;         // Default to ADD
    endcase
end

endmodule
