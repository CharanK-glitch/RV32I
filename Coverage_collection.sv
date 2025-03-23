// File: riscv_coverage.sv
class riscv_coverage extends uvm_subscriber#(axi_transaction);
    `uvm_component_utils(riscv_coverage)
    
    covergroup axi_cg;
        addr_cp: coverpoint tr.addr {
            bins axi_mem = {['h40000000:'h4FFFFFFF]};
            bins gpio    = {['h20000000:'h2FFFFFFF]};
            bins uart    = {['h30000000:'h3FFFFFFF]};
        }
        kind_cp: coverpoint tr.kind;
        size_cp: coverpoint tr.size;
        cross kind_cp, size_cp;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_cg = new();
    endfunction

    virtual function void write(axi_transaction tr);
        axi_cg.sample();
    endfunction
endclass
