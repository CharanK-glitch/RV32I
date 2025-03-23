// File: riscv_tb.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

// Agent for AXI4-Lite interface
`include "axi_agent.sv"

// Register Abstraction Layer
`include "ral/riscv_ral.sv"

// Test Components
`include "riscv_scoreboard.sv"
`include "riscv_coverage.sv"
`include "riscv_vseq_lib.sv"

module riscv_tb;
    import uvm_pkg::*;
    import riscv_pkg::*;

    // Clock and Reset
    bit clk;
    bit resetn;

    // DUT Interface
    riscv_if dut_if(clk, resetn);

    // DUT Instance
    riscv_soc dut(
        .clk(clk),
        .resetn(resetn),
        .axi(dut_if.axi),
        .gpio(dut_if.gpio),
        .uart(dut_if.uart)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // UVM Initialization
    initial begin
        uvm_config_db#(virtual riscv_if)::set(null, "*", "vif", dut_if);
        run_test("riscv_base_test");
    end
endmodule
