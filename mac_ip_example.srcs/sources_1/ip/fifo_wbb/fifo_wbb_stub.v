// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Wed Sep 04 15:52:23 2019
// Host        : aujus-PC running 64-bit major release  (build 7600)
// Command     : write_verilog -force -mode synth_stub
//               I:/ac701_SAC/mac_ip_example.srcs/sources_1/ip/fifo_wbb/fifo_wbb_stub.v
// Design      : fifo_wbb
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_1,Vivado 2016.2" *)
module fifo_wbb(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty, valid, rd_data_count, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[7:0],wr_en,rd_en,dout[7:0],full,empty,valid,rd_data_count[9:0],wr_data_count[9:0]" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [7:0]din;
  input wr_en;
  input rd_en;
  output [7:0]dout;
  output full;
  output empty;
  output valid;
  output [9:0]rd_data_count;
  output [9:0]wr_data_count;
endmodule
