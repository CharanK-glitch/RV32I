// File: ral/riscv_ral.sv
class riscv_reg_block extends uvm_reg_block;
    `uvm_object_utils(riscv_reg_block)

    rand uvm_reg_map axi_map;
    rand uvm_reg_map gpio_map;
    rand uvm_reg_map uart_map;

    // AXI Control Registers
    rand uvm_reg axi_ctrl;
    rand uvm_reg axi_status;

    // GPIO Registers
    rand uvm_reg gpio_dir;
    rand uvm_reg gpio_out;
    rand uvm_reg gpio_in;

    // UART Registers
    rand uvm_reg uart_txdata;
    rand uvm_reg uart_rxdata;
    rand uvm_reg uart_status;

    function new(string name = "riscv_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        // Build register definitions
        // ...
        // Create address maps
        axi_map = create_map("axi_map", 'h40000000, 4, UVM_LITTLE_ENDIAN);
        gpio_map = create_map("gpio_map", 'h20000000, 4, UVM_LITTLE_ENDIAN);
        uart_map = create_map("uart_map", 'h30000000, 4, UVM_LITTLE_ENDIAN);
    endfunction
endclass
