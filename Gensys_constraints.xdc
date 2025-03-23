# Clock
set_property PACKAGE_PIN E3 [get_ports clk100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk100mhz]

# Switches
set_property PACKAGE_PIN D9 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

# LEDs
set_property PACKAGE_PIN H5 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# UART
set_property PACKAGE_PIN A9 [get_ports uart_tx]
set_property PACKAGE_PIN D10 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_*]
