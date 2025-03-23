// File: riscv_env.sv
class riscv_env extends uvm_env;
    `uvm_component_utils(riscv_env)
    
    axi_agent axi_agt;
    gpio_agent gpio_agt;
    uart_agent uart_agt;
    riscv_scoreboard scbd;
    riscv_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agt = axi_agent::type_id::create("axi_agt", this);
        gpio_agt = gpio_agent::type_id::create("gpio_agt", this);
        uart_agt = uart_agent::type_id::create("uart_agt", this);
        scbd = riscv_scoreboard::type_id::create("scbd", this);
        cov = riscv_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_agt.ap.connect(scbd.axi_imp);
        gpio_agt.ap.connect(scbd.gpio_imp);
        uart_agt.ap.connect(scbd.uart_imp);
        axi_agt.ap.connect(cov.axi_export);
    endfunction
endclass
