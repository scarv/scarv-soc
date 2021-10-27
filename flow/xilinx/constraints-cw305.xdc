set_property PACKAGE_PIN N13 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]

set_property PACKAGE_PIN R1 [get_ports sys_reset]
set_property IOSTANDARD LVCMOS33 [get_ports sys_reset]

set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { uart_txd}]; # IO1
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd}]; # IO2

set_property PACKAGE_PIN B16 [get_ports {gpio_trig_tri_o[0]}]
set_property SLEW FAST [get_ports {gpio_trig_tri_o[0]}]    
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_trig_tri_o[0]}]

set_property PACKAGE_PIN A12 [get_ports {gpio_led_tri_o[9]}]
set_property PACKAGE_PIN A14 [get_ports {gpio_led_tri_o[8]}]
set_property PACKAGE_PIN A15 [get_ports {gpio_led_tri_o[7]}]
set_property PACKAGE_PIN C12 [get_ports {gpio_led_tri_o[6]}]
set_property PACKAGE_PIN B12 [get_ports {gpio_led_tri_o[5]}]
set_property PACKAGE_PIN A13 [get_ports {gpio_led_tri_o[4]}]
set_property PACKAGE_PIN B15 [get_ports {gpio_led_tri_o[3]}]
set_property PACKAGE_PIN C11 [get_ports {gpio_led_tri_o[2]}]
set_property PACKAGE_PIN B14 [get_ports {gpio_led_tri_o[1]}]
set_property PACKAGE_PIN C14 [get_ports {gpio_led_tri_o[0]}]                     

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_tri_o[0]}]

