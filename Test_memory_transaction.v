initial begin
    // Write to AXI memory
    soc.core.mem_addr = 32'h4000_0000;
    soc.core.mem_wdata = 32'h12345678;
    soc.core.mem_we = 1;
    #100;
    
    // Read from peripheral
    soc.core.mem_addr = 32'h20000000;
    soc.core.mem_re = 1;
    #100;
end
