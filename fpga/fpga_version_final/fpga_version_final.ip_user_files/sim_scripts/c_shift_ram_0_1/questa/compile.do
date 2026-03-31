vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" \
"../../../../ascon_version_registre.gen/sources_1/ip/c_shift_ram_0_1/c_shift_ram_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

