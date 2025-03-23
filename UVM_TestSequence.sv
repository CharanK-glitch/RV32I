// File: riscv_vseq_lib.sv
class riscv_base_vseq extends uvm_sequence;
    `uvm_object_utils(riscv_base_vseq)
    `uvm_declare_p_sequencer(riscv_vsequencer)

    riscv_reg_block regmodel;
    virtual riscv_if vif;

    task pre_start();
        if(!uvm_config_db#(riscv_reg_block)::get(null, "", "regmodel", regmodel))
            `uvm_fatal("NO_REG", "Register model not found")
        if(!uvm_config_db#(virtual riscv_if)::get(null, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endtask

    task body();
        // Common test setup
        vif.reset();
        regmodel.reset();
    endtask
endclass

class axi_smoke_vseq extends riscv_base_vseq;
    `uvm_object_utils(axi_smoke_vseq)

    task body();
        super.body();
        // AXI Basic Read/Write
        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
            addr inside {['h40000000:'h4FFFFFFF]};
            kind == WRITE;
        });
        finish_item(tr);
    endtask
endclass
