onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+mac_ip -L unisims_ver -L unimacro_ver -L secureip -L xbip_utils_v3_0_6 -L xbip_pipe_v3_0_2 -L xbip_bram18k_v3_0_2 -L mult_gen_v12_0_11 -L axi_lite_ipif_v3_0_4 -L tri_mode_ethernet_mac_v9_0_5 -L xil_defaultlib -O5 xil_defaultlib.mac_ip xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {mac_ip.udo}

run -all

endsim

quit -force
