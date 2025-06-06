`timescale 1ns/1ps

// ==============================================
// Control Unit for RV32I Processor
// ==============================================

// Instruction type definitions
`define R_type        3'b000
`define I_type        3'b001
`define I_type_load   3'b010
`define S_type        3'b011
`define B_type        3'b100
`define U_type_LUI    3'b101
`define J_type        3'b110
`define U_type_AUIPC  3'b111

// ALU operation definitions
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

// Instruction type detection
wire r_type = (opcode_in == 7'b0110011);
wire i_type = (opcode_in == 7'b0010011);
assign i_type_load = (opcode_in == 7'b0000011);
wire s_type = (opcode_in == 7'b0100011);
wire b_type = (opcode_in == 7'b1100011);
wire i_type_jalr = (opcode_in == 7'b1100111);
wire j_type = (opcode_in == 7'b1101111) || i_type_jalr;
wire u_type_lui = (opcode_in == 7'b0110111);
wire u_type_auipc = (opcode_in == 7'b0010111);

// Control signals
assign bypass_ir2 = r_type || s_type || b_type;
assign out_u_type = u_type_lui || u_type_auipc;
assign bypass_ir1 = ~(j_type || out_u_type);
assign sb_type = b_type || s_type;
assign stall = i_type_load && ~load_type_in;
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
            // Instruction type decoding
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
            
            // ALU operation decoding
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
            
            // Control signals generation
            werf_contrl = ~op_format_out[1] | op_format_out[0];
            
            case (op_format_out)
                `R_type, `I_type: wbmux_contol = 2'b00;
                `I_type_load:     wbmux_contol = 2'b01;
                `J_type:         wbmux_contol = 2'b10;
                default:         wbmux_contol = 2'b00;
            endcase
            
            ir_mux = {2{(~op_format_out[0] & ~op_format_out[2]) | (~op_format_out[2] & ~op_format_out[1])}};
            
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

// ==============================================
// Testbench for Control Unit
// ==============================================

module tb_control_unit;
    // Inputs
    reg clk;
    reg reset;
    reg load_type_in;
    reg [6:0] opcode_in;
    reg [2:0] funct3_in;
    reg funct7_in;
    
    // Outputs
    wire werf_contrl;
    wire [1:0] wbmux_contol;
    wire [3:0] aluop;
    wire [1:0] ir_mux;
    wire stall;
    wire [2:0] op_format_out;
    wire bypass_ir1;
    wire bypass_ir2;
    wire sb_type;
    wire out_u_type;
    wire reg_u_type_lui;
    wire ready_in;
    wire i_type_load;
    
    // Instantiate Unit Under Test
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .load_type_in(load_type_in),
        .opcode_in(opcode_in),
        .funct3_in(funct3_in),
        .funct7_in(funct7_in),
        .werf_contrl(werf_contrl),
        .wbmux_contol(wbmux_contol),
        .aluop(aluop),
        .ir_mux(ir_mux),
        .stall(stall),
        .op_format_out(op_format_out),
        .bypass_ir1(bypass_ir1),
        .bypass_ir2(bypass_ir2),
        .sb_type(sb_type),
        .out_u_type(out_u_type),
        .reg_u_type_lui(reg_u_type_lui),
        .ready_in(ready_in),
        .i_type_load(i_type_load)
    );
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        // Initialize and reset
        reset = 1;
        load_type_in = 0;
        opcode_in = 0;
        funct3_in = 0;
        funct7_in = 0;
        #20 reset = 0;
        
        // Test R-type instructions
        $display("\n=== Testing R-type Instructions ===");
        opcode_in = 7'b0110011;
        
        // ADD
        funct3_in = 3'b000; funct7_in = 0;
        #10 check_outputs("ADD", `ADD, 1, 0);
        
        // SUB
        funct7_in = 1;
        #10 check_outputs("SUB", `SUB, 1, 0);
        
        // AND
        funct3_in = 3'b111; funct7_in = 0;
        #10 check_outputs("AND", `AND, 1, 0);
        
        // Test I-type instructions
        $display("\n=== Testing I-type Instructions ===");
        opcode_in = 7'b0010011;
        
        // ADDI
        funct3_in = 3'b000;
        #10 check_outputs("ADDI", `ADD, 1, 0);
        
        // SRAI
        funct3_in = 3'b101; funct7_in = 1;
        #10 check_outputs("SRAI", `SRA, 1, 0);
        
        // Test Load/Store
        $display("\n=== Testing Load/Store ===");
        opcode_in = 7'b0000011; // Load
        funct3_in = 3'b010;
        #10 check_outputs("LW", `ADD, 1, 1);
        
        opcode_in = 7'b0100011; // Store
        #10 check_outputs("SW", `ADD, 0, 0);
        
        // Test Branches
        $display("\n=== Testing Branches ===");
        opcode_in = 7'b1100011;
        funct3_in = 3'b000; // BEQ
        #10 check_outputs("BEQ", `ADD, 0, 0);
        
        // Test Jumps
        $display("\n=== Testing Jumps ===");
        opcode_in = 7'b1101111; // JAL
        #10 check_outputs("JAL", `ADD, 1, 2);
        
        opcode_in = 7'b1100111; // JALR
        #10 check_outputs("JALR", `ADD, 1, 0);
        
        // Test U-type
        $display("\n=== Testing U-type ===");
        opcode_in = 7'b0110111; // LUI
        #10 check_outputs("LUI", `ADD, 1, 0);
        
        opcode_in = 7'b0010111; // AUIPC
        #10 check_outputs("AUIPC", `ADD, 1, 0);
        
        // Test load stall
        $display("\n=== Testing Load Stall ===");
        opcode_in = 7'b0000011; // Load
        load_type_in = 0;
        #10;
        $display("Stall signal during load: %b (expected 1)", stall);
        load_type_in = 1;
        #10;
        $display("Stall signal after load: %b (expected 0)", stall);
        
        // Finish simulation
        #20;
        $display("\nAll tests completed successfully!");
        $finish;
    end
    
    // Helper task to verify outputs
    task check_outputs;
        input [80:0] instr_name;
        input [3:0] expected_aluop;
        input expected_werf;
        input [1:0] expected_wbmux;
    begin
        if (aluop !== expected_aluop || werf_contrl !== expected_werf || 
            wbmux_contol !== expected_wbmux) begin
            $display("ERROR: %s - ALUop=%b (exp %b), werf=%b (exp %b), wbmux=%b (exp %b)",
                    instr_name, aluop, expected_aluop, 
                    werf_contrl, expected_werf,
                    wbmux_contol, expected_wbmux);
            $finish;
        end
        else begin
            $display("PASS: %s", instr_name);
        end
    end
    endtask
    
    // Monitor to track important signals
    initial begin
        $monitor("Time=%0t: opcode=%7b funct3=%3b | ALUop=%4b Format=%3b WERF=%b WBMux=%2b",
                $time, opcode_in, funct3_in, aluop, op_format_out, werf_contrl, wbmux_contol);
    end
endmodule
