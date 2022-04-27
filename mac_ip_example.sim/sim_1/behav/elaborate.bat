@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xelab  -wto 80d905714e3b41529c91a1736292caeb -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L xpm -L fifo_generator_v13_1_1 -L xbip_utils_v3_0_6 -L xbip_pipe_v3_0_2 -L xbip_bram18k_v3_0_2 -L mult_gen_v12_0_11 -L axi_lite_ipif_v3_0_4 -L tri_mode_ethernet_mac_v9_0_5 -L blk_mem_gen_v8_3_3 -L unisims_ver -L unimacro_ver -L secureip --snapshot demo_tb_behav xil_defaultlib.demo_tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
