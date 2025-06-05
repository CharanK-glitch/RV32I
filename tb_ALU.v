`timescale 1ns/1ps

module ALU_tb;

    // Inputs
    reg [31:0] operand_1;
    reg [31:0] operand_2;
    reg [3:0] aluop;

    // Output
    wire [31:0] out;

    // Instantiate the ALU
    ALU uut (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .aluop(aluop),
        .out(out)
    );

    // VCD for waveform
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, ALU_tb);
    end

    // Test stimulus
    initial begin
        // Test ADD
        operand_1 = 32'd10; operand_2 = 32'd5; aluop = 4'b0000; #10;
        $display("ADD 10 + 5 = %d, out = %d", operand_1, out);

        // Test SUB
        operand_1 = 32'd15; operand_2 = 32'd7; aluop = 4'b0001; #10;
        $display("SUB 15 - 7 = %d, out = %d", operand_1, out);

        // Test AND
        operand_1 = 32'hFF00FF00; operand_2 = 32'h0F0F0F0F; aluop = 4'b0100; #10;
        $display("AND: out = %h", out);

        // Test OR
        operand_1 = 32'hFF00FF00; operand_2 = 32'h0F0F0F0F; aluop = 4'b0011; #10;
        $display("OR: out = %h", out);

        // Test XOR
        operand_1 = 32'hAAAAAAAA; operand_2 = 32'h55555555; aluop = 4'b0010; #10;
        $display("XOR: out = %h", out);

        // Test SLL
        operand_1 = 32'h00000001; operand_2 = 32'd4; aluop = 4'b0101; #10;
        $display("SLL: out = %h", out);

        // Test SRL
        operand_1 = 32'hF0000000; operand_2 = 32'd4; aluop = 4'b0110; #10;
        $display("SRL: out = %h", out);

        // Test SRA
        operand_1 = 32'hF0000000; operand_2 = 32'd4; aluop = 4'b0111; #10;
        $display("SRA: out = %h", out);

        // Test SLT (signed)
        operand_1 = -5; operand_2 = 10; aluop = 4'b1000; #10;
        $display("SLT (-5 < 10): out = %d", out);

        // Test SLTU (unsigned)
        operand_1 = 32'hFFFFFFF0; operand_2 = 32'd1; aluop = 4'b1001; #10;
        $display("SLTU: out = %d", out);

        // Done
        $display("Testbench completed.");
        $finish;
    end

endmodule
