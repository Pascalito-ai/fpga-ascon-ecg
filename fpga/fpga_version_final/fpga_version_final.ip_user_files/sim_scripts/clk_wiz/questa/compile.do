vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz" \
"C:/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz" \
"../../../../ascon_version_registre_enhanced_final.gen/sources_1/ip/clk_wiz/clk_wiz_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"

