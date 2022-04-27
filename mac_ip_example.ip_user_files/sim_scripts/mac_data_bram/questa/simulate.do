onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib mac_data_bram_opt

do {wave.do}

view wave
view structure
view signals

do {mac_data_bram.udo}

run -all

quit -force
