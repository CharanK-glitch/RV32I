module stall_unit (
    input  imem_ready,   // Instruction memory ready signal
    output stall         // Stall signal to pipeline stages
);
    assign stall = ~imem_ready; // Assert stall when memory is not ready
endmodule
