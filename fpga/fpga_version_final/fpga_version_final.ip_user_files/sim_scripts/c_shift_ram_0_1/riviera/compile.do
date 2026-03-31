transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" -l xil_defaultlib \
"../../../../ascon_version_registre.gen/sources_1/ip/c_shift_ram_0_1/c_shift_ram_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

