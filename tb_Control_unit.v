`timescale 1ns/1ps
`include "control_unit.v"

module control_unit_tb;
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
    
    // Instantiate the Unit Under Test (UUT)
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
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test procedure
    initial begin
        // Initialize Inputs
        reset = 1;
        load_type_in = 0;
        opcode_in = 0;
        funct3_in = 0;
        funct7_in = 0;
        
        // Wait 10 ns for global reset
        #10;
        reset = 0;
        
        // Test R-type instructions
        $display("Testing R-type instructions");
        opcode_in = 7'b0110011; // R-type opcode
        
        // Test ADD/SUB
        funct3_in = 3'b000;
        funct7_in = 0; // ADD
        #10;
        $display("ADD: aluop=%b, werf=%b, wbmux=%b", aluop, werf_contrl, wbmux_contol);
        
        funct7_in = 1; // SUB
        #10;
        $display("SUB: aluop=%b, werf=%b, wbmux=%b", aluop, werf_contrl, wbmux_contol);
        
        // Test other R-type operations
        funct3_in = 3'b111; // AND
        funct7_in = 0;
        #10;
        $display("AND: aluop=%b", aluop);
        
        // Test I-type instructions
        $display("\nTesting I-type instructions");
        opcode_in = 7'b0010011; // I-type opcode
        
        funct3_in = 3'b000; // ADDI
        #10;
        $display("ADDI: aluop=%b", aluop);
        
        funct3_in = 3'b101; // SRAI/SRLI
        funct7_in = 1; // SRAI
        #10;
        $display("SRAI: aluop=%b", aluop);
        
        // Test Load instructions
        $display("\nTesting Load instructions");
        opcode_in = 7'b0000011; // Load opcode
        funct3_in = 3'b010; // LW
        #10;
        $display("LW: aluop=%b, stall=%b", aluop, stall);
        
        // Test Store instructions
        $display("\nTesting Store instructions");
        opcode_in = 7'b0100011; // Store opcode
        funct3_in = 3'b010; // SW
        #10;
        $display("SW: aluop=%b, sb_type=%b", aluop, sb_type);
        
        // Test Branch instructions
        $display("\nTesting Branch instructions");
        opcode_in = 7'b1100011; // Branch opcode
        funct3_in = 3'b000; // BEQ
        #10;
        $display("BEQ: aluop=%b, sb_type=%b", aluop, sb_type);
        
        // Test JAL
        $display("\nTesting JAL");
        opcode_in = 7'b1101111; // JAL opcode
        #10;
        $display("JAL: ready_in=%b, wbmux=%b", ready_in, wbmux_contol);
        
        // Test JALR
        $display("\nTesting JALR");
        opcode_in = 7'b1100111; // JALR opcode
        #10;
        $display("JALR: ready_in=%b", ready_in);
        
        // Test LUI
        $display("\nTesting LUI");
        opcode_in = 7'b0110111; // LUI opcode
        #10;
        $display("LUI: out_u_type=%b, reg_u_type_lui=%b", out_u_type, reg_u_type_lui);
        
        // Test AUIPC
        $display("\nTesting AUIPC");
        opcode_in = 7'b0010111; // AUIPC opcode
        #10;
        $display("AUIPC: out_u_type=%b", out_u_type);
        
        // Test load stall condition
        $display("\nTesting load stall");
        opcode_in = 7'b0000011; // Load opcode
        load_type_in = 0; // Simulate cache miss
        #10;
        $display("Load with stall: stall=%b", stall);
        load_type_in = 1; // Cache fill complete
        #10;
        $display("Load complete: stall=%b", stall);
        
        // Finish simulation
        #10;
        $display("All tests completed");
        $finish;
    end
    
    // Monitor to track signals
    initial begin
        $monitor("Time=%0t opcode=%b funct3=%b aluop=%b format=%b", 
                $time, opcode_in, funct3_in, aluop, op_format_out);
    end
endmodule
