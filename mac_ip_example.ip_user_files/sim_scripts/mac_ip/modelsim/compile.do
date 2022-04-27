vlib work
vlib msim

vlib msim/xbip_utils_v3_0_6
vlib msim/xbip_pipe_v3_0_2
vlib msim/xbip_bram18k_v3_0_2
vlib msim/mult_gen_v12_0_11
vlib msim/axi_lite_ipif_v3_0_4
vlib msim/tri_mode_ethernet_mac_v9_0_5
vlib msim/xil_defaultlib

vmap xbip_utils_v3_0_6 msim/xbip_utils_v3_0_6
vmap xbip_pipe_v3_0_2 msim/xbip_pipe_v3_0_2
vmap xbip_bram18k_v3_0_2 msim/xbip_bram18k_v3_0_2
vmap mult_gen_v12_0_11 msim/mult_gen_v12_0_11
vmap axi_lite_ipif_v3_0_4 msim/axi_lite_ipif_v3_0_4
vmap tri_mode_ethernet_mac_v9_0_5 msim/tri_mode_ethernet_mac_v9_0_5
vmap xil_defaultlib msim/xil_defaultlib

vcom -work xbip_utils_v3_0_6 -64 -93 \
"../../../ipstatic/xbip_utils_v3_0_6/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_2 -64 -93 \
"../../../ipstatic/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0.vhd" \

vcom -work xbip_bram18k_v3_0_2 -64 -93 \
"../../../ipstatic/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0.vhd" \

vcom -work mult_gen_v12_0_11 -64 -93 \
"../../../ipstatic/mult_gen_v12_0_11/hdl/mult_gen_v12_0_vh_rfs.vhd" \
"../../../ipstatic/mult_gen_v12_0_11/hdl/mult_gen_v12_0.vhd" \

vcom -work axi_lite_ipif_v3_0_4 -64 -93 \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/ipif_pkg.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/pselect_f.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/address_decoder.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/slave_attachment.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/axi_lite_ipif.vhd" \

vlog -work tri_mode_ethernet_mac_v9_0_5 -64 -incr \
"../../../ipstatic/tri_mode_ethernet_mac_v9_0_5/hdl/tri_mode_ethernet_mac_v9_0_rfs.v" \

vcom -work tri_mode_ethernet_mac_v9_0_5 -64 -93 \
"../../../ipstatic/tri_mode_ethernet_mac_v9_0_5/hdl/tri_mode_ethernet_mac_v9_0_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/common/mac_ip_block_sync_block.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/axi_ipif/mac_ip_axi4_lite_ipif_wrapper.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/physical/mac_ip_rgmii_v2_0_if.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/mac_ip_block.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/mac_ip.vhd" \

vlog -work xil_defaultlib "glbl.v"

