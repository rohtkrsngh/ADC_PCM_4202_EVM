vlib work
vlib activehdl

vlib activehdl/xbip_utils_v3_0_6
vlib activehdl/xbip_pipe_v3_0_2
vlib activehdl/xbip_bram18k_v3_0_2
vlib activehdl/mult_gen_v12_0_11
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/tri_mode_ethernet_mac_v9_0_5
vlib activehdl/xil_defaultlib

vmap xbip_utils_v3_0_6 activehdl/xbip_utils_v3_0_6
vmap xbip_pipe_v3_0_2 activehdl/xbip_pipe_v3_0_2
vmap xbip_bram18k_v3_0_2 activehdl/xbip_bram18k_v3_0_2
vmap mult_gen_v12_0_11 activehdl/mult_gen_v12_0_11
vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap tri_mode_ethernet_mac_v9_0_5 activehdl/tri_mode_ethernet_mac_v9_0_5
vmap xil_defaultlib activehdl/xil_defaultlib

vcom -work xbip_utils_v3_0_6 -93 \
"../../../ipstatic/xbip_utils_v3_0_6/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_2 -93 \
"../../../ipstatic/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_pipe_v3_0_2/hdl/xbip_pipe_v3_0.vhd" \

vcom -work xbip_bram18k_v3_0_2 -93 \
"../../../ipstatic/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_bram18k_v3_0_2/hdl/xbip_bram18k_v3_0.vhd" \

vcom -work mult_gen_v12_0_11 -93 \
"../../../ipstatic/mult_gen_v12_0_11/hdl/mult_gen_v12_0_vh_rfs.vhd" \
"../../../ipstatic/mult_gen_v12_0_11/hdl/mult_gen_v12_0.vhd" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/ipif_pkg.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/pselect_f.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/address_decoder.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/slave_attachment.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0_4/hdl/src/vhdl/axi_lite_ipif.vhd" \

vlog -work tri_mode_ethernet_mac_v9_0_5 -v2k5 \
"../../../ipstatic/tri_mode_ethernet_mac_v9_0_5/hdl/tri_mode_ethernet_mac_v9_0_rfs.v" \

vcom -work tri_mode_ethernet_mac_v9_0_5 -93 \
"../../../ipstatic/tri_mode_ethernet_mac_v9_0_5/hdl/tri_mode_ethernet_mac_v9_0_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/common/mac_ip_block_sync_block.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/axi_ipif/mac_ip_axi4_lite_ipif_wrapper.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/physical/mac_ip_rgmii_v2_0_if.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/mac_ip_block.vhd" \
"../../../../mac_ip_example.srcs/sources_1/ip/mac_ip/synth/mac_ip.vhd" \

vlog -work xil_defaultlib "glbl.v"

