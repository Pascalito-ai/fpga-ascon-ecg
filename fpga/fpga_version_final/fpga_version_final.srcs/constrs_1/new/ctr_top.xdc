## Clock signal 125 MHz

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clock_i]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports clock_i]

##Buttons
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports rest_btn_i]

##PmodA

set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports RTS_o]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports Tx_o]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports Rx_i]


set_property MARK_DEBUG true [get_nets RTS_o_OBUF]
set_property MARK_DEBUG true [get_nets Rx_i_IBUF]
set_property MARK_DEBUG true [get_nets en_led_s]
set_property MARK_DEBUG true [get_nets {RxData_s[0]}]
set_property MARK_DEBUG true [get_nets {RxData_s[1]}]
set_property MARK_DEBUG true [get_nets {RxData_s[2]}]
set_property MARK_DEBUG true [get_nets {RxData_s[3]}]
set_property MARK_DEBUG true [get_nets {RxData_s[4]}]
set_property MARK_DEBUG true [get_nets {RxData_s[5]}]
set_property MARK_DEBUG true [get_nets {RxData_s[6]}]
set_property MARK_DEBUG true [get_nets {RxData_s[7]}]

