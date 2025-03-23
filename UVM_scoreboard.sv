// File: riscv_scoreboard.sv
class riscv_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(riscv_scoreboard)
    
    uvm_analysis_imp#(axi_transaction, riscv_scoreboard) axi_imp;
    uvm_analysis_imp#(gpio_transaction, riscv_scoreboard) gpio_imp;
    uvm_analysis_imp#(uart_transaction, riscv_scoreboard) uart_imp;

    // Reference Model
    riscv_ref_model ref_model;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ref_model = riscv_ref_model::type_id::create("ref_model", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_imp = new("axi_imp", this);
        gpio_imp = new("gpio_imp", this);
        uart_imp = new("uart_imp", this);
    endfunction

    virtual function void write_axi(axi_transaction tr);
        // Compare with reference model
        ref_model.process_axi(tr);
        if(ref_model.get_status() != tr.status)
            `uvm_error("SCBD", $sformatf("AXI Mismatch! Exp: %0h Got: %0h", 
                        ref_model.get_status(), tr.status))
    endfunction

    // Similar functions for GPIO and UART
endclass
