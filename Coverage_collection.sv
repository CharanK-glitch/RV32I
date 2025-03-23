class riscv_coverage extends uvm_subscriber#(axi_transaction);
    `uvm_component_utils(riscv_coverage)

    covergroup axi_cg;
        addr_cp: coverpoint tr.addr {
            bins axi_mem = {['h40000000:'h4FFFFFFF]};
            bins gpio    = {['h20000000:'h2FFFFFFF]};
            bins uart    = {['h30000000:'h3FFFFFFF]};
        }
        kind_cp: coverpoint tr.kind {
            bins read  = {0};
            bins write = {1};
        }
        size_cp: coverpoint tr.size {
            bins small  = {[1:4]};
            bins medium = {[5:16]};
            bins large  = {[17:32]};
        }
        cross kind_cp, size_cp;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write(axi_transaction tr);
        axi_cg.sample();
    endfunction
endclass

