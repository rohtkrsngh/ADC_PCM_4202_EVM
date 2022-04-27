// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Thu Feb 21 15:46:23 2019
// Host        : aujus-PC running 64-bit major release  (build 7600)
// Command     : write_verilog -force -mode synth_stub
//               i:/rgmii/viv16/mac_ip_example/mac_ip_example.srcs/sources_1/ip/mac_data_bram/mac_data_bram_stub.v
// Design      : mac_data_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_3,Vivado 2016.2" *)
module mac_data_bram(clka, wea, addra, dina, clkb, rstb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[6:0],dina[7:0],clkb,rstb,addrb[6:0],doutb[7:0]" */;
  input clka;
  input [0:0]wea;
  input [6:0]addra;
  input [7:0]dina;
  input clkb;
  input rstb;
  input [6:0]addrb;
  output [7:0]doutb;
endmodule
