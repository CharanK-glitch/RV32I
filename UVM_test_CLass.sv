// File: riscv_test_lib.sv
class riscv_base_test extends uvm_test;
    `uvm_component_utils(riscv_base_test)
    
    riscv_env env;
    riscv_reg_block regmodel;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = riscv_env::type_id::create("env", this);
        regmodel = riscv_reg_block::type_id::create("regmodel");
        regmodel.build();
        uvm_config_db#(riscv_reg_block)::set(this, "*", "regmodel", regmodel);
    endfunction

    virtual task run_phase(uvm_phase phase);
        riscv_base_vseq vseq;
        phase.raise_objection(this);
        vseq = riscv_base_vseq::type_id::create("vseq");
        vseq.start(null);
        phase.drop_objection(this);
    endtask
endclass
