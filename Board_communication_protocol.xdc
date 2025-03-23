# riscv_soc.xdc
create_clock -period 10 [get_ports clk]

set_property PACKAGE_PIN F5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN D4 [get_ports resetn]
set_property IOSTANDARD LVCMOS33 [get_ports resetn]

# UART pins
set_property PACKAGE_PIN C5 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
