// File: axi_agent.sv
class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)
    
    uvm_analysis_port #(axi_transaction) ap;
    axi_driver    driver;
    axi_monitor   monitor;
    axi_sequencer sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = axi_monitor::type_id::create("monitor", this);
        driver = axi_driver::type_id::create("driver", this);
        sequencer = axi_sequencer::type_id::create("sequencer", this);
        ap = new("ap", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        monitor.ap.connect(ap);
    endfunction
endclass
