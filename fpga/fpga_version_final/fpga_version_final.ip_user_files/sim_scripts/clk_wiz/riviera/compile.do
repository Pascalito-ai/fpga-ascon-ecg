transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz" -l xpm -l xil_defaultlib \
"C:/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz" -l xpm -l xil_defaultlib \
"../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz/clk_wiz_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"

