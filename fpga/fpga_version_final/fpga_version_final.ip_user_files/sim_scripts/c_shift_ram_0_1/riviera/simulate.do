transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+c_shift_ram_0  -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.c_shift_ram_0 xil_defaultlib.glbl

do {c_shift_ram_0.udo}

run 1000ns

endsim

quit -force
