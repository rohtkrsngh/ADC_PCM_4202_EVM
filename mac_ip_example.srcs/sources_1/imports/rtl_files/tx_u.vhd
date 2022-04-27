
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity tx_u is
    Port ( 
				    RST_ESB :  in STD_LOGIC;
				  clk_input :  in std_logic;
	            CLK_125_ESB :  in STD_LOGIC;
                     clk_20 :  in std_logic;
				    clk_100 :  in std_logic;
                  DIN_ESB_s :  in STD_LOGIC_VECTOR (7 downto 0);
              DIN_VALID_ESB :  in STD_LOGIC;
                 Rd_Req_UMC :  in  std_logic; 
			   addr_data_in :  in std_logic_Vector(6 downto 0);
				 wr_en_bram :  in  std_logic_vector(0 downto 0);
				    new_pkt :  in  std_logic;
			 	en_clk_4mhz :  out  std_logic; 
			  en_clk_195khz :  out  std_logic;
                    uart_ch :  out std_logic;
				 valid_uart :  out std_logic_vector(3 downto 0);
			   self_test_rx :  out  std_logic;
			   frame_length :  out std_logic_vector(7 downto 0);
			  format_recvr  :  out std_logic;
                  DOUT_ESB  :  out STD_LOGIC;
			 self_dout_test :  out  std_logic;
                    LEN_UMC :  out STD_LOGIC_VECTOR(7 downto 0);
             Data_Valid_UMC :  out STD_LOGIC;
			           rf_p :  out std_logic_vector(7 downto 0);
			     reset_dut1 :  out std_logic;
			   PCPU100u_DUT : out std_logic_Vector(3 downto 0);
			  PCPU100u_dutq : out std_logic_Vector(3 downto 0); 
		   cmd_id_DUT_num_q : out std_logic_vector(3 downto 0);
				
				    rx_data :  out STD_LOGIC_VECTOR(7 downto 0);
			 monitor_enable :  out std_logic_vector(3 downto 0);    
				 trm_psu_on :  out std_logic;	
			   trm_psu_off	:  out std_logic;   
		   self_monitor_txd :  out std_logic;
	         	      TRP_p :  out std_logic;
	         	    rx_sclk : out std_logic;
			gen_preselect_pulse, gen_tx_pulse_pulse, 
			gen_datawindow_pulse, gen_beamini_pulse, 
			gen_beamhop_pulse, gen_clkref_pulse, gen_tx_pulse_pulse_v,
		    gen_pdusync_pulse :   out  std_logic;
		enable_pcpu_rd_status : out std_logic_Vector(3 downto 0);	
				gen_pcpu_test : out std_logic_Vector(7 downto 0); 
			  TRIB_PDU_SYNC :  out std_logic;		
			   rx_pkt_cmplt :  in  std_logic_vector(3 downto 0);
				
		gen_monitor_txd_pulse, gen_PSU_OFF_pulse,
		  gen_PSU_On_pulse ,   
		    gen_reset_pulse :  out  std_logic;
			gen_monitor_enable_pulse : out std_logic_vector(3 downto 0)	;
			pw_pre_select, pw_rf_pulse, pw_data_wind,pw_rf_pulse_v,
			pw_beam_ini, pw_beam_hop  :  out  std_logic_vector(15 downto 0)
       );
end tx_u;

architecture beh of tx_u is



signal F_rf_p               :  std_logic_vector(7 downto 0);
signal DIN_VALID_ESB_s2     : std_logic;
signal DIN_ESB_s_pul        : std_logic_vector(7 downto 0):= (others => '0');

signal SPI_Ch_En_s          : std_logic_vector(3 downto 0):="0000";
signal DOUT_ESB_ut          : std_logic;
signal Spi_Ch_Dis_s             : std_logic_vector(3 downto 0):="0000"; -- update 27 aug
signal cmd_id_uart ,cmd_id_st   : std_logic;

constant CMD_Id1_c         : std_logic_vector(7 downto 0) := x"01";                                      
constant CMD_Id2_c         : std_logic_vector(7 downto 0) := x"02";
constant CMD_Id3_c         : std_logic_vector(7 downto 0) := x"03";
constant CMD_Id4_c         : std_logic_vector(7 downto 0) := x"04";
constant CMD_Id5_c         : std_logic_vector(7 downto 0) := x"05";
constant CMD_Id6_c         : std_logic_vector(7 downto 0) := x"06";
constant CMD_Id7_c         : std_logic_vector(7 downto 0) := x"07";
constant CMD_Id8_c         : std_logic_vector(7 downto 0) := x"08";
constant CMD_Id9_c         : std_logic_vector(7 downto 0) := x"09";
constant CMD_Id_AA         : std_logic_vector(7 downto 0) := x"AA";
constant CMD_Id_CD         : std_logic_vector(7 downto 0) := x"CD";  --  
constant CMD_Id_CC         : std_logic_vector(7 downto 0) := x"CC";
constant CMD_Id_AB         : std_logic_vector(7 downto 0) := x"AB";
constant CMD_Id_45         : std_logic_vector(7 downto 0) := x"45";

signal monitor_enable_sig : std_logic;
signal      ch_sel_q      : std_logic_vector(5 downto 0):="000000";
signal      ch_sel        : std_logic_vector(5 downto 0):="000000";

signal CMD_Id_clk    : std_logic:='0';
signal enable_pulse1 : std_logic:='0';
signal enable_pulse2 : std_logic:='0';
signal enable_ref    : std_logic:='0';
signal enable_trp1   : std_logic:='0';
signal enable_rf1    : std_logic:='0';
signal enable_rf2    : std_logic:='0';
signal enable_rf3    : std_logic:='0';
signal enable_rf4 : std_logic:='0';
signal enable_rf5  : std_logic:='0';
signal enable_rf6 : std_logic:='0';
signal enable_rf7 : std_logic:='0';
signal enable_rf8 : std_logic:='0';


signal valid_dut_s  : std_logic_vector(1 downto 0):="00";
SIGNAL CMD_ID_spi      : STD_LOGIC := '0';
SIGNAL CMD_ID_PULSE    : STD_LOGIC;
SIGNAL CMD_ID_DUT1     : STD_LOGIC := '0';
SIGNAL CMD_ID_DUT2     : STD_LOGIC := '0';
SIGNAL   cmd_id_reset    : STD_LOGIC  := '0';
SIGNAL   gen_reset_mod   : STD_LOGIC  := '0';

signal PRT1        : std_logic_vector(31 downto 0) := (others => '0');
signal P_W_TRP1    : std_logic_vector(15 downto 0) := (others => '0');
signal start_trp1  : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF1   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF1 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF2   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF2 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF3   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF3 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF4   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF4 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF5   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF5 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF6   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF6 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF7   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF7 : std_logic_vector(31 downto 0) := (others => '0');
signal F_P_W_RF8   : std_logic_vector(15 downto 0) := (others => '0');
signal F_start_RF8 : std_logic_vector(31 downto 0) := (others => '0');
signal active_reset : std_logic := '1';
SIGNAL strp_p         :    std_logic;
SIGNAL en_self_data_out :  std_logic;
SIGNAL en_self_self_in  :  std_logic;
signal din_reg        :   stD_logic_vector(7 downto 0);
signal rd_en_fifo3    :  std_logic;
signal rd_en_fifo4    :  std_logic;
signal check_dut      :  std_logic:= '0';
type state  is (idle, chsel_st1, chsel_st2, wait_st1, wait_st2, wait_uart, 
                opmode_st1, uart1_st1, uart1_st2, uart1_st21,
                	uart1_st3, pulse_st1, pulse_st2, pulse_st3 );
  
  signal next_st, pres_st    :  state;

  signal count_addr          :  std_logic_vector(6 downto 0); 
  signal count_addr_Q        :  std_logic_vector(6 downto 0); 

  signal count_bram_addr     :  std_logic_vector(6 downto 0); 
  signal en_bram_rd_addr     :  std_logic_vector(1 downto 0);
  signal en_count_bram_data  :  std_logic_vector(1 downto 0);
  signal en_ch_sel           :  std_logic;
  signal en_chsel_mod        :  std_logic;
  signal en_data_tx          :  std_logic; 
  signal en_change_clk       :  std_logic;
  signal count_Txdata        :  std_logic_vector(7 downto 0);  
  signal length_frame        :  std_logic_vector(7 downto 0);  
  signal len_frame_bit       :  std_logic_vector(8 downto 0):=(others=>'0');  
  
  signal en_pulse_frame      :  std_logic;
  signal count_frame_data    :  std_logic_vector(6 downto 0); 
  signal data_bram_out       :  std_logic_vector(7 downto 0);
  signal data_rate_val       :   std_logic_vector( 7 downto 0);

  signal din_Esb_tx2         :  std_logic_vector( 7 downto 0);
  signal sob_spi_en          :  std_logic_vector( 1 downto 0);
  signal reset_in_mod        :  std_logic;
  signal reset_out_mod       :  std_logic;
  Signal wait_count          :  std_logic_vector(15 downto 0):=(others=>'0');
component sel_clk_Mod is
port
 (  --inputs
  i_reset         :  in std_logic;
  i_clk_200       :  in std_logic;
  i_clk_125       :  in std_logic;
  rx_sclk         : out std_logic; 
  self_rx_en      :  in std_logic;
  o_sclk          : out std_logic
  );
  
end component;

component fifo1
PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    underflow : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
end component;

component TX2 is
    Port ( CLK_125 : in STD_LOGIC;
           clk_tx: in std_logic;
           DIN : in STD_LOGIC_VECTOR (7 downto 0);
			  rd_en_fifo : out std_logic;
			  valid_s  :  in  std_logic;
			  busy : out std_logic;
           RST : in STD_LOGIC;
           En_tx  : IN std_logic;
			  len_frame_byt    : in  std_logic_vector(7 downto 0);
			  TX_out               : OUT STD_LOGIC);
end component TX2;


component pulse_dist 
port(clk,enable_ref,enable_rf1,enable_rf2,enable_rf3, reset_in,
          enable_rf4,enable_rf5,enable_rf6,enable_rf7,enable_rf8,enable_trp: in std_logic; PRT: in std_logic_vector(31 downto 0);
beam_ini_gap	: in std_logic_vector(7 downto 0);	
beam_hop_gap	: in std_logic_vector(7 downto 0);
	P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 P_W_RF1: in std_logic_vector(15 downto 0);
		 start_RF1: in std_logic_vector(31 downto 0); 
		 P_W_RF2: in std_logic_vector(15 downto 0);
		 start_RF2: in std_logic_vector(31 downto 0);
		 P_W_RF3: in std_logic_vector(15 downto 0);
		 start_RF3: in std_logic_vector(31 downto 0);
		 P_W_RF4: in std_logic_vector(15 downto 0);
		 start_RF4: in std_logic_vector(31 downto 0);
		 P_W_RF5: in std_logic_vector(15 downto 0);
		 start_RF5: in std_logic_vector(31 downto 0);
		 P_W_RF6: in std_logic_vector(15 downto 0);
		 start_RF6: in std_logic_vector(31 downto 0);
		 P_W_RF7: in std_logic_vector(15 downto 0);
		 start_RF7: in std_logic_vector(31 downto 0);
		 P_W_RF8: in std_logic_vector(15 downto 0);
		 start_RF8: in std_logic_vector(31 downto 0);
		 rf_p: out std_logic_vector(7 downto 0);
		 trp_p: out std_logic
		 );

end component;


signal         no_use    :   std_logic;

COMPONENT mac_data_bram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;



component DUT_signal_modle is
port ( clk  	:		in		std_logic;
       clk_100 :		in		std_logic;
		 reset	:		in		std_logic;
		 
		 en_monitor_enable	:	in	std_logic;
		 val_monitor_enable	:	in	std_logic_vector(7 downto 0);
		 
		 en_PSU_On				:	in	std_logic;
		 val_PSU_ON				:	in	std_logic_vector(7 downto 0);
		 
		 en_PSU_off				:	in	std_logic;
		 val_psu_off			:	in	std_logic_vector(7 downto 0);
		 
		 en_Self_monitor_txd	:	in	std_logic;
		 val_self_monitor_txd:	in	std_logic_vector(7 downto 0);
		 
		 monitor_enable		:	out	std_logic;
		 trm_psu_on				:	out	std_logic;
		 trm_psu_off			:	out	std_logic;
		 self_monitor_txd		:	out	std_logic);
end component;


signal Tx_clk  : std_logic;
signal sel_dut1 ,sel_dut2  :  std_logic;



signal gen_monitor_enable_pulse_sig : std_logic;
signal rd_en_fifo1       :   std_logic;
signal rd_en_fifo_q        :   std_logic;
signal full:std_logic;
signal overflow: std_logic;
signal empty: std_logic;
signal valid: std_logic;
signal  underflow :  STD_LOGIC;
signal rd_data_count: std_logic_vector(6 downto 0);
signal wr_data_count : std_logic_vector(6 downto 0);
signal addr_data_bram : std_logic_vector(6 downto 0);
signal wr_en_fifo     :  std_logic;

SIGNAL len_frame_byt    :  STD_LOGIC_VECTOR(7 downto 0) ;
SIGNAL len_frame_byt_rx :  STD_LOGIC_VECTOR(7 downto 0) ;

SIGNAL svalid_uart      :  std_logic_Vector(1 downto 0);
component reset_generator is
port ( clk ,reset_in   : in std_logic;
         reset_enable  : in  std_logic;
         reset_out     : out std_logic);
end component;

component pcpu_gen is
port ( clk ,reset_in   : in std_logic;
         reset_enable  : in  std_logic;
         reset_out     : out std_logic);
end component;

component rf1_Pulse
port(clk,enable,ref_sig: in std_logic; 
       P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 rf_p: out std_logic);
end component;


SIGNAL reset_sig     :    std_logic := '0';
signal reset_format  :    std_logic_Vector(7 downto 0) := X"00";
signal reset_format2 :    std_logic_Vector(7 downto 0) := X"00";
signal beam_hop_gap  :    std_logic_Vector(7 downto 0);
signal beam_ini_gap  :    std_logic_Vector(7 downto 0);
SIGNAL en_monitor_enable	   :    std_logic := '0';
SIGNAL val_monitor_enable	   :    std_logic_Vector(7 downto 0) := X"00";
SIGNAL en_PSU_On					:    std_logic := '0';
SIGNAL val_PSU_ON					:    std_logic_Vector(7 downto 0) := X"00";	
SIGNAL en_PSU_off				   :    std_logic := '0';
SIGNAL val_psu_off			   :    std_logic_Vector(7 downto 0) := X"00";
SIGNAL en_Self_monitor_txd	   :    std_logic := '0';
SIGNAL val_self_monitor_txd   :    std_logic_Vector(7 downto 0) := X"00";
signal cmd_id_DUT_num : std_logic_vector(3 downto 0);	
signal valid_uart_sig : std_logic;
signal gen_pcpu_mod : std_logic;
signal gen_pcpu_mod2 : std_logic;
signal PCPU100u_sig  : std_logic;
signal PCPU100u_sig2 : std_logic;
signal self_rx_en : std_logic;
signal gen_pcpu_status : std_logic;
signal format_reset : std_logic := '0';
begin

format_recvr  <= format_reset;
 ch_sel <= CMD_Id_reset & CMD_ID_PULSE & Cmd_Id_spi & 
             Cmd_Id_uart & "00";
				 
				 

 self_dout_test  <=   DOUT_ESB_ut when (en_self_data_out=  '1') else '1';
				 
						
----------------------------Data Capture ---------------------------


DOUT_ESB      <=   DOUT_ESB_ut ; 

valid_uart(0) <= valid_uart_sig when cmd_id_DUT_num = X"1" else '0';  
valid_uart(1) <= valid_uart_sig when cmd_id_DUT_num = X"2" else '0';  
valid_uart(2) <= valid_uart_sig when cmd_id_DUT_num = X"3" else '0';  
valid_uart(3) <= valid_uart_sig when cmd_id_DUT_num = X"4" else '0';  

PCPU100u_dut(0)  <= PCPU100u_sig when cmd_id_DUT_num = X"1" else '0';
PCPU100u_dut(1)  <= PCPU100u_sig when cmd_id_DUT_num = X"2" else '0';
PCPU100u_dut(2)  <= PCPU100u_sig when cmd_id_DUT_num = X"3" else '0';
PCPU100u_dut(3)  <= PCPU100u_sig when cmd_id_DUT_num = X"4" else '0';

PCPU100u_dutq(0)  <= PCPU100u_sig2 when cmd_id_DUT_num = X"1" else '0';
PCPU100u_dutq(1)  <= PCPU100u_sig2 when cmd_id_DUT_num = X"2" else '0';
PCPU100u_dutq(2)  <= PCPU100u_sig2 when cmd_id_DUT_num = X"3" else '0';
PCPU100u_dutq(3)  <= PCPU100u_sig2 when cmd_id_DUT_num = X"4" else '0';
TRP_p            <= strp_p;
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
 cmd_id_DUT_num_q <= cmd_id_DUT_num;
   if count_addr_Q =  "0000100" then
	  reset_format2  <=  DIN_ESB_s_pul;
	 end if;
 end if;
end process;

process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if count_addr_Q =  "0000010" then
	  reset_format  <=  DIN_ESB_s_pul;
	 end if;
 end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then	
	if count_addr_Q = "0000001"  then  
		    if DIN_ESB_s_pul = X"01"  then
			  cmd_id_DUT_num   <=   X"1";
          elsif DIN_ESB_s_pul = X"02"  then
			  cmd_id_DUT_num   <=   X"2";
          elsif DIN_ESB_s_pul = X"03"  then
              cmd_id_DUT_num   <=   X"3";
           elsif DIN_ESB_s_pul = X"04"  then
              cmd_id_DUT_num   <=   X"4";                 			  
          else
			  cmd_id_DUT_num   <=   X"0";
          end if;
      end if;
    end if;	
	
end process;


--process (clk_125_ESB)
--begin
-- if rising_edge(clk_125_ESB) then
--	 if reset_format = X"FF" then
--	  reset_dut1   <=   reset_sig;
--	  else
--	  reset_dut1   <=    reset_sig;
--	 end if;
-- end if;
--end process;


 process (CLK_125_ESB) 
begin
if rising_Edge(CLK_125_ESB)  then
 IF en_chsel_mod = '1' THEN
  ch_sel_q   <=  ch_sel;
 end if;
end if;
end process;

process (CLK_125_ESB) 
begin
 if rst_esb  = '1' then
  next_st <=  idle;
 elsif rising_Edge(CLK_125_ESB)  then
  next_st  <= pres_st;
 end if;
end process;


process(next_St, DIN_VALID_ESB, count_addr_q, ch_sel_q,new_pkt,
       Spi_Ch_Dis_s,count_Txdata, count_frame_data ,wait_count,rx_pkt_cmplt  )
 begin
 case next_st is 
   when idle  =>
	   en_bram_rd_addr    <=  "00";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
		 
		 if DIN_VALID_ESB = '1' then
		  pres_st  <=  chsel_St1;
		 else
		  pres_St  <=  idle;
		 end if;
	
	when chsel_st1 =>
	   en_bram_rd_addr    <=  "11";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';

		if count_addr_q = "0000101" then
		 pres_st  <=  chsel_St2;
		 else
		 pres_st  <=  chsel_St1;
		end if;
	
   when 	chsel_st2 =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '1';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
	   
		pres_st            <=  wait_st1;
	
	when wait_st1   =>
      en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';	
		--wr_en_bram         <=    "0";
		
		pres_st            <=  wait_st2;
	
	when wait_st2   =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '1';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
	
	pres_st     <=  opmode_st1;
	
	when opmode_st1   =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
	
	  if ch_sel_q = "000100" then
	    pres_st     <=  uart1_st1;
	  
	  elsif ( ch_sel_q = "010000") then
	    pres_st     <=  pulse_st1;
	  else
	    pres_st     <=  idle;
	  end if;
	 

	when uart1_st1    =>
		en_bram_rd_addr    <=  "11";
		en_count_bram_data <=  "11";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "1";
		
		if (count_Txdata  =  length_frame - '1') then
		 pres_st     <=  wait_uart;
		--wr_en_bram         <=    "0";
		 
		else
		--wr_en_bram         <=    "1";
		 pres_st     <=  uart1_st1;
		 end if;
	 
	 when wait_uart   =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "01";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  "0000";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0'; 
	
	    if (wait_count > X"1A") then   -- AFFF
		   pres_st           <=  uart1_st2;
         else
		  pres_st            <=  wait_uart;
       end if;
	
    when uart1_st2    =>	
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s(3 downto 1)  <=  "000";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
	    
		 if (Spi_Ch_Dis_s(0) = '0') then
		   pres_st           <=  uart1_st21;
         SPI_Ch_En_s(0)    <=  '1';
         else
        SPI_Ch_En_s(0)    <=  '0';
		  pres_st           <=  uart1_st2;
       end if;
	
    when uart1_st21    =>	
	   
		en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s(3 downto 1)  <=  "000";
		sel_dut1           <=   '0';
		uart_ch            <=   '1';
	   svalid_uart        <=   "01";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
		
	   
    	 if (Spi_Ch_Dis_s(0) = '0') then
		   pres_st           <=  uart1_st21;
         SPI_Ch_En_s(0)    <=  '1';
         else
        SPI_Ch_En_s(0)    <=  '0';
		  pres_st           <=  uart1_st3;
       end if;

	
	 when uart1_st3    =>	
	   
		en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '1';
	   
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
		--wr_en_bram         <=    "0";
		
	   
     
		if new_pkt = '1' then
      	pres_st     <=  idle; 
			svalid_uart        <=   "00";		
     else
	  svalid_uart        <=   "01";
         pres_st     <=  uart1_st3;
     end if;
	    

  when pulse_st1  =>
      en_bram_rd_addr    <=  "11";
		en_count_bram_data <=  "10";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '0';
	  
   	if count_frame_data  =  "1100111" then 
		--wr_en_bram         <=    "0";
       pres_st      <=   pulse_st2;
		else
		--wr_en_bram         <=    "1";
		 pres_st      <=   pulse_st1;
		end if;
			
  
	when pulse_st2   =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=   '1';
		--wr_en_bram         <=    "0";
		
		pres_st      <=   pulse_st3;
	
	when pulse_st3   =>
	   en_bram_rd_addr    <=  "01";
		en_count_bram_data <=  "00";
		en_ch_sel          <=   '0';
      en_chsel_mod       <=   '0';
	   en_data_tx         <=   '0';
	   en_change_clk      <=   '0';
	   SPI_Ch_En_s        <=  X"0";
		sel_dut1           <=   '0';
		uart_ch            <=   '0';
	   svalid_uart        <=   "00";
		sel_dut2           <=   '0';
       
	   en_pulse_frame     <=  '0';
		--wr_en_bram         <=    "0";
		
		pres_st            <=    idle;
	end case;
end process;

length_frame   <=  len_frame_byt;

process(CLK_125_ESB)
 begin
  if rising_Edge(CLK_125_ESB) then
	 frame_length  <=  len_frame_byt_rx;
  end if;
end process;
  
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"3E")  then
			   gen_reset_mod   <=  '1';
				else
				gen_reset_mod   <=  '0';
			  end if;
	   elsif new_pkt = '1' then
		gen_reset_mod   <=  '0';
    end if;
end if;
end process;	 

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"9C")  then
			   gen_pcpu_mod   <=  '1';
				else
				gen_pcpu_mod   <=  '0';
			  end if;
	   elsif new_pkt = '1' then
		gen_pcpu_mod   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"94")  then
			   gen_pcpu_mod2   <=  '1';
				else
				gen_pcpu_mod2   <=  '0';
			  end if;
	   elsif new_pkt = '1' then
		gen_pcpu_mod2   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"9D")  then
			   gen_pcpu_status   <=  '1';
				else
				gen_pcpu_status   <=  '0';
			  end if;
	   else
                              gen_pcpu_status   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
    if ( gen_pcpu_status = '1')  then
      if cmd_id_DUT_num = X"1" then
       enable_pcpu_rd_status <= X"1";
      elsif  cmd_id_DUT_num = X"2" then
       enable_pcpu_rd_status <= X"2";
      elsif  cmd_id_DUT_num = X"3" then
       enable_pcpu_rd_status <= X"4";
      elsif  cmd_id_DUT_num = X"4" then
       enable_pcpu_rd_status <= X"8";
      end if;
     else
       enable_pcpu_rd_status <= X"0";
     end if;
   end if;
 end process;    

process(CLK_125_ESB)
 begin
  if rising_Edge(CLK_125_ESB) then
    if cmd_id_DUT_num = X"1" then
      monitor_enable <= "000" & monitor_enable_sig;
    elsif cmd_id_DUT_num = X"2" then
     monitor_enable <= "00" & monitor_enable_sig & '0';
    elsif cmd_id_DUT_num = X"3" then
      monitor_enable <= '0' & monitor_enable_sig & "00";     
    elsif cmd_id_DUT_num = X"4" then
       monitor_enable <=  monitor_enable_sig & "000";
	end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
           if (DIN_ESB_s_pul = X"BE")  then
            format_reset   <=   '1';
           end if;
       elsif  new_pkt = '1' then
          format_reset   <=   '0';  
        end if;
        end if;
end process;

	
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
           if (DIN_ESB_s_pul = X"A1")  then
            active_reset   <=   '0';
           elsif (DIN_ESB_s_pul = X"A0")  then
             active_reset   <=   '1';
           end if;
        end if;
        end if;
 end process;
 
-- process(CLK_125_ESB)
--  begin
--    if rising_Edge(CLK_125_ESB) then
--     if   active_reset = '0' then        
--	  reset_dut1   <=   reset_sig;
--	 else
--	  reset_dut1   <=  not reset_sig;
--	 end if;
--	end if;
--end process;
	reset_dut1   <=  not reset_sig; 
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	  
           if (DIN_ESB_s_pul = X"A5")  then
			     Cmd_Id_uart   <=  '1';
				  cmd_id_reset  <=  '0';
              CMD_ID_PULSE  <=  '0';
          
			 elsif DIN_ESB_s_pul = X"CD" then
			    Cmd_Id_uart   <=  '0';			 
			    cmd_id_reset  <=  '0';
             CMD_ID_PULSE  <=  '1';
		    elsif DIN_ESB_s_pul = X"FF" then 
			    Cmd_Id_uart   <=  '0';			 
			    cmd_id_reset  <=  '1';
             CMD_ID_PULSE  <=  '0';
          else
			    Cmd_Id_uart   <=  '0';			 
			    cmd_id_reset  <=  '0';
             CMD_ID_PULSE  <=  '0';
			 
          end if;
	 	
end if;
end if;
end process;	


process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if count_addr_Q =  "0000101" then
	  len_frame_byt   <=  DIN_ESB_s_pul;
	 end if;
 end if;
end process;
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if count_addr_Q =  "0000100" then
     if DIN_ESB_s_pul = X"AB" then
     self_rx_en <= '1';
	  else
	  self_rx_en <= '0' ;
	 end if;
	end if; 
 end if;
end process;


DIN_ESB_s_pul    <=    data_bram_out;
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
  DIN_VALID_ESB_s2 <=    en_chsel_mod;
  count_addr_q     <=    count_addr;
 -- DIN_ESB_s_pul    <=    data_bram_out;
  end if;
 end process;
 
 
 
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if en_bram_rd_addr  =  "11" then
	 count_addr  <=  count_addr  + 1;
	 elsif en_bram_rd_addr  =  "00" then
	 count_addr  <=  (others=>'0');
	 elsif en_bram_rd_addr  =  "01" then
	 count_addr  <=  count_addr;
	 else
	 count_addr  <=  (others=>'0');
	end if;
 end if;
end process;

addr_data_bram     <=   count_addr;

process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if en_count_bram_data  =  "11" then
      wr_en_fifo  <=  '1';
	 else
      wr_en_fifo  <=  '0';
	end if;
 end if;
end process;
	  

process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
   if en_count_bram_data  =  "11" then
	  count_Txdata       <=  count_Txdata + 1;
	  count_frame_data   <=  (others=>'0');
	  wait_count         <=  (others=>'0');
	 elsif en_count_bram_data  =  "00" then
	  count_Txdata       <=  (others=>'0');
	  count_frame_data   <=  (others=>'0');
	  wait_count         <=  (others=>'0');
	 elsif en_count_bram_data  =  "10" then
	  count_frame_data   <=  count_frame_data + 1;
	  count_Txdata       <=  (others=>'0');
	  wait_count         <=  (others=>'0');
	 elsif en_count_bram_data  =  "01" then
	  wait_count         <=  wait_count + '1';
	  count_Txdata       <=  (others=>'0');
	  count_frame_data   <=  (others=>'0');
	 else
	  count_Txdata       <=  (others=>'0');
	  count_frame_data   <=  (others=>'0');
	  wait_count         <=  (others=>'0');

	end if;
 end if;
end process;
----
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
  if cmd_id_pulse = '1' then
 --  if ch_sel_q /= "000000" then
    enable_trp1   <= '1';
    enable_pulse1 <= '1';
  elsif ch_sel_q = "000000" then
	-- enable_ref    <= '0';
    enable_trp1   <= '0';
    enable_pulse1 <= '0';
	end if;
--	end if;
 end if;
end process; 


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B0")  then
			   en_monitor_enable   <=  '1';
				else
				en_monitor_enable   <=  '0';
			  end if;
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B1")  then
			   gen_monitor_enable_pulse_sig   <=  '1';
				else
				gen_monitor_enable_pulse_sig   <=  '0';
			  end if;
	  else
		gen_monitor_enable_pulse_sig   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
  if rising_Edge(CLK_125_ESB) then
    if cmd_id_DUT_num = X"1" then
      gen_monitor_enable_pulse <= "000" & gen_monitor_enable_pulse_sig;
    elsif cmd_id_DUT_num = X"2" then
     gen_monitor_enable_pulse <= "00" & gen_monitor_enable_pulse_sig & '0';
    elsif cmd_id_DUT_num = X"3" then
      gen_monitor_enable_pulse <= '0' & gen_monitor_enable_pulse_sig & "00";     
    elsif cmd_id_DUT_num = X"4" then
       gen_monitor_enable_pulse <=  gen_monitor_enable_pulse_sig & "000";
	end if;
end if;
end process;


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	   if  DIN_ESB_s_pul  = X"59"  then  
		  en_self_self_in   <=   '1';
		 else
		 en_self_self_in   <=   '0';
     end if;
	  end if;
	  end if;
end process;


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	   if  DIN_ESB_s_pul  = X"60"  then
		  en_self_data_out   <=   '1';
		 else
		 en_self_data_out   <=   '0';
     end if;
	  end if;
	  end if;
end process;	  
		 
		 


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000111" then
	   val_monitor_enable   <=   DIN_ESB_s_pul;
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B2")  then
			   en_PSU_On   <=  '1';
				else
				en_PSU_On   <=  '0';
			  end if;
	  else
			 en_PSU_On   <=  '0';		  
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	      if (DIN_ESB_s_pul = X"B3")  then
			   gen_PSU_On_pulse   <=  '1';
				else
				gen_PSU_On_pulse   <=  '0';
			  end if;
	  else
		gen_PSU_On_pulse   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000111" then
	   val_psu_on   <=   DIN_ESB_s_pul   ;
    end if;
end if;
end process;


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B4")  then
			   en_PSU_off   <=  '1';
				else
				en_PSU_Off   <=  '0';
			  end if;
	  else
				en_PSU_Off   <=  '0';		  
    end if;
end if;
end process;
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	      if (DIN_ESB_s_pul = X"B5")  then
			   gen_PSU_OFF_pulse   <=  '1';
				else
				gen_PSU_OFF_pulse   <=  '0';
			  end if;
	  else
		gen_PSU_OFF_pulse   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000111" then
	   val_psu_off   <=   DIN_ESB_s_pul   ;
    end if;
end if;
end process;




process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B6")  then
			   en_Self_monitor_txd   <=  '1';
				else
				en_Self_monitor_txd   <=  '0';
			  end if;
    end if;
end if;
end process;
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"B7")  then
			   gen_monitor_txd_pulse   <=  '1';
				else
				gen_monitor_txd_pulse   <=  '0';
			  end if;
	  else
		gen_monitor_txd_pulse   <=  '0';
    end if;
end if;
end process;
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000111" then
	   val_Self_monitor_txd   <=   DIN_ESB_s_pul   ;
    end if;
end if;
end process;	


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"51")  then
			   gen_preselect_pulse   <=  '1';
				else
				gen_preselect_pulse   <=  '0';
			  end if;
	  else
		gen_preselect_pulse   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"52")  then
			   gen_tx_pulse_pulse   <=  '1';
				else
				gen_tx_pulse_pulse   <=  '0';
			  end if;
	  else
		gen_tx_pulse_pulse   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"53")  then
			   gen_datawindow_pulse   <=  '1';
				else
				gen_datawindow_pulse   <=  '0';
			  end if;
	  else
		gen_datawindow_pulse   <=  '0';
    end if;
end if;
end process;
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"54")  then
			   gen_beamini_pulse   <=  '1';
				else
				gen_beamini_pulse   <=  '0';
			  end if;
	  else
		gen_beamini_pulse   <=  '0';
    end if;
end if;
end process;


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"55")  then
			   gen_beamhop_pulse   <=  '1';
				else
				gen_beamhop_pulse   <=  '0';
			  end if;
	  else
		gen_beamhop_pulse   <=  '0';
    end if;
end if;
end process;
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"56")  then
			   gen_tx_pulse_pulse_v   <=  '1';
				else
				gen_tx_pulse_pulse_v   <=  '0';
			  end if;
	  else
		gen_tx_pulse_pulse_v   <=  '0';
    end if;
end if;
end process;
 
process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"57")  then
			   gen_pdusync_pulse   <=  '1';
				else
				gen_pdusync_pulse   <=  '0';
			  end if;
	  else
		gen_pdusync_pulse   <=  '0';
    end if;
end if;
end process;


process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	      if (DIN_ESB_s_pul = X"58")  then
			   gen_reset_pulse   <=  '1';
				else
				gen_reset_pulse   <=  '0';
			  end if;
	  else
		gen_reset_pulse   <=  '0';
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	  if  count_addr_Q =  "0000011" then
	      if (DIN_ESB_s_pul = X"71")  then
		  gen_pcpu_test   <=  X"01";
		  elsif (DIN_ESB_s_pul = X"72")  then
           gen_pcpu_test   <=  X"02";
           elsif (DIN_ESB_s_pul = X"73")  then
           gen_pcpu_test   <=  X"04";
           elsif (DIN_ESB_s_pul = X"74")  then
           gen_pcpu_test   <=  X"08";
           elsif (DIN_ESB_s_pul = X"75")  then
           gen_pcpu_test   <=  X"10";           
           elsif (DIN_ESB_s_pul = X"76")  then
           gen_pcpu_test   <=  X"20";
           elsif (DIN_ESB_s_pul = X"77")  then
           gen_pcpu_test   <=  X"40";           
           elsif (DIN_ESB_s_pul = X"78")  then
           gen_pcpu_test   <=  X"80";                      		
             else
		  gen_pcpu_test   <=  X"00";
		  end if;
	  else
		gen_pcpu_test   <=  X"00";
    end if;
end if;
end process;






process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	if RST_ESB  =  '1'  then
	   en_clk_4mhz   <=  '0';
	elsif  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"91")  then 
			   en_clk_4mhz   <=  '1';
			elsif (DIN_ESB_s_pul = X"92")  then
				en_clk_4mhz   <=  '0';
			end if;		  
    end if;
end if;
end process;

process(CLK_125_ESB)
 begin
   if rising_Edge(CLK_125_ESB) then
	if RST_ESB  =  '1'  then
	   en_clk_195khz   <=  '0';
	elsif  count_addr_Q =  "0000110" then
	      if (DIN_ESB_s_pul = X"81")  then 
			   en_clk_195khz   <=  '1';
			elsif (DIN_ESB_s_pul = X"82")  then
				en_clk_195khz   <=  '0';
			end if;		  
    end if;
end if;
end process;
  

		
process(clk_125_ESB)
begin
 if rising_edge(clk_125_ESB) then
  if ch_sel_q /= "000000" then
   case  count_frame_data is
	 when "0000001"   =>
					enable_rf1    <= DIN_ESB_s_pul(0);
					enable_rf2    <= DIN_ESB_s_pul(1);
					enable_rf3    <= DIN_ESB_s_pul(2);
					enable_rf4    <= DIN_ESB_s_pul(3);
					enable_rf5    <= DIN_ESB_s_pul(4);
					enable_rf6    <= DIN_ESB_s_pul(5);
					enable_rf7    <= DIN_ESB_s_pul(6);
					enable_rf8    <= DIN_ESB_s_pul(7);
					enable_ref    <= '0';
               beam_ini_gap   <=  reset_format;
					beam_hop_gap   <=  reset_format2;
	
	 when "0000010"   =>
	            PRT1(31 downto 24) <=  DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0000011"   =>
	            PRT1(23 downto 16) <=  DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0000100"   =>
	            PRT1(15 downto 8) <=  DIN_ESB_s_pul;
               enable_ref    <= '0';					
	 when "0000101"   =>
	            PRT1(7 downto 0) <=  DIN_ESB_s_pul;
enable_ref    <= '0';					

	 when "0000110"   =>
	            P_W_TRP1(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0000111"   =>
	            P_W_TRP1(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0001000"   =>
	            F_P_W_RF1(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0001001"   =>
	            F_P_W_RF1(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
   when "0001010"   =>
	            F_P_W_RF2(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0001011"   =>
	            F_P_W_RF2(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
   when "0001100"   =>
	            F_P_W_RF3(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0001101"   =>
	            F_P_W_RF3(7 downto 0)  <=   DIN_ESB_s_pul;	
					enable_ref    <= '0';
	 when "0001110"   =>
	            F_P_W_RF4(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0001111"   =>
	            F_P_W_RF4(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
   when "0010000"   =>
	            F_P_W_RF5(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0010001"   =>
	            F_P_W_RF5(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
   when "0010010"   =>
	            F_P_W_RF6(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0010011"   =>
	            F_P_W_RF6(7 downto 0)  <=   DIN_ESB_s_pul;	 
					enable_ref    <= '0';
   when "0010100"   =>
	            F_P_W_RF7(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0010101"   =>
	            F_P_W_RF7(7 downto 0)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
   when "0010110"   =>
	            F_P_W_RF8(15 downto 8)  <=   DIN_ESB_s_pul;
					enable_ref    <= '0';
	 when "0010111"   =>
	            F_P_W_RF8(7 downto 0)  <=   DIN_ESB_s_pul;					
	 when "0011000"   =>
	           start_trp1(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0011001"   =>
	            start_trp1(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0011010"   =>
	            start_trp1(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0011011"   =>
	            start_trp1(7 downto 0) <=  DIN_ESB_s_pul;
	  
	 when "0011100"   =>
	           F_start_RF1(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0011101"   =>
	            F_start_RF1(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0011110"   =>
	            F_start_RF1(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0011111"   =>
	            F_start_RF1(7 downto 0) <=  DIN_ESB_s_pul;
	   
  
	 when "0100000"   =>
	           F_start_RF2(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0100001"   =>
	            F_start_RF2(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0100010"   =>
	            F_start_RF2(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0100011"   =>
	            F_start_RF2(7 downto 0) <=  DIN_ESB_s_pul;	 

  
	 when "0100100"   =>
	           F_start_RF3(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0100101"   =>
	            F_start_RF3(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0100110"   =>
	            F_start_RF3(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0100111"   =>
	            F_start_RF3(7 downto 0) <=  DIN_ESB_s_pul;
	
  
	 when "0101000"   =>
	           F_start_RF4(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0101001"   =>
	            F_start_RF4(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0101010"   =>
	            F_start_RF4(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0101011"   =>
	            F_start_RF4(7 downto 0) <=  DIN_ESB_s_pul;	

  
	 when "0101100"   =>
	           F_start_RF5(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0101101"   =>
	            F_start_RF5(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0101110"   =>
	            F_start_RF5(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0101111"   =>
	            F_start_RF5(7 downto 0) <=  DIN_ESB_s_pul;	

  
	 when "0110000"   =>
	           F_start_RF6(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0110001"   =>
	            F_start_RF6(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0110010"   =>
	            F_start_RF6(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0110011"   =>
	            F_start_RF6(7 downto 0) <=  DIN_ESB_s_pul;	

  
	 when "0110100"   =>
	           F_start_RF7(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0110101"   =>
	            F_start_RF7(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0110110"   =>
	            F_start_RF7(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0110111"   =>
	            F_start_RF7(7 downto 0) <=  DIN_ESB_s_pul;		

  
	 when "0111000"   =>
	           F_start_RF8(31 downto 24) <=  DIN_ESB_s_pul;
					
	 when "0111001"   =>
	            F_start_RF8(23 downto 16) <=  DIN_ESB_s_pul;
	 when "0111010"   =>
	            F_start_RF8(15 downto 8) <=  DIN_ESB_s_pul;					
	 when "0111011"   =>
	            F_start_RF8(7 downto 0) <=  DIN_ESB_s_pul;	
					enable_ref    <= '1';
    when others =>
   	-- enable_pulse1  <=  enable_pulse1;
		null;
  end case;

-- else
--
--					enable_rf1    <=   '0';--
--					enable_rf2    <=   '0';--
--					enable_rf3    <=   '0';--
--					enable_rf4    <=   '0';--
--					enable_rf5    <=   '0';--
--					enable_rf6    <=   '0';--
--					enable_rf7    <=   '0';--
--					enable_rf8    <=   '0';--
--					enable_ref    <=   '0';
--
--					PRT1           <=   (others=>'0');--
--					P_W_TRP1       <=   (others=>'0');--
--					F_P_W_RF1      <=   (others=>'0');--
--					F_P_W_RF2      <=   (others=>'0');--
--					F_P_W_RF3      <=   (others=>'0');--
--					F_P_W_RF4      <=   (others=>'0');--
--					F_P_W_RF5      <=   (others=>'0');--
--					F_P_W_RF6      <=   (others=>'0');--
--					F_P_W_RF7      <=   (others=>'0');--
--					F_P_W_RF8      <=   (others=>'0');--
--
--					start_trp1     <=  (others=>'0');--
--					F_start_RF1    <=  (others=>'0');-- 
--					F_start_RF2    <=  (others=>'0');-- 
--					F_start_RF3    <=  (others=>'0');-- 
--					F_start_RF4    <=  (others=>'0');-- 
--					F_start_RF5    <=  (others=>'0');-- 
--					F_start_RF6    <=  (others=>'0');-- 
--					F_start_RF7    <=  (others=>'0');-- 
--					F_start_RF8    <=  (others=>'0');-- 
	end if;
end if;
end process;	
--	

process(CLK_125_ESB) is
begin
 if rising_edge(CLK_125_ESB) then
 -- if new_pkt = '1'	then
  valid_uart_sig  <=       '1';
 
 end if; 
 end process;
 
 process(CLK_125_ESB) is
begin
 if rising_edge(CLK_125_ESB) then
 if en_self_self_in =  '1' then
    self_test_rx  <=   svalid_uart(0);
else
self_test_rx  <=  '0';
end if;
 end if;
 end process;
 

 

---------------------------- INSTANTIATION --------------------------------------------------------

 U1: sel_clk_Mod
   port map
	      (
			   i_reset         =>     rst_esb,
			   i_clk_200       =>     clk_input,
			   i_clk_125       =>     CLK_125_ESB,
			    rx_sclk        =>     rx_sclk,
			    self_rx_en    =>  self_rx_en,
               o_sclk          =>     Tx_clk
			 );
				

------					 
					  
U2 : TX2 PORT map
      (CLK_125       => clk_125_esb,
        RST          => rst_esb,
       clk_tx        => Tx_clk,
       valid_s       => valid,	
	    din           => din_Esb_tx2,
	    busy          => Spi_Ch_Dis_s(0),
	    en_tx         => SPI_Ch_En_s(0),
		rd_en_fifo     => rd_en_fifo1,
		len_frame_byt  => len_frame_byt,
	   TX_out         => DOUT_ESB_ut);



U3 :  reset_generator port map( 
                            clk       	 =>  CLK_100,
						  reset_in 		 =>  rst_esb,
						  reset_enable	 =>  gen_reset_mod,
						  reset_out 	 =>  reset_sig    );




U4 : mac_data_bram
  PORT MAP (
    clka  => CLK_125_ESB,
    wea   => wr_en_bram,
    addra =>  addr_data_in,
    dina  => DIN_ESB_s,
    clkb  => CLK_125_ESB,
    rstb  => rst_esb,
    addrb =>  addr_data_bram,
    doutb => data_bram_out
  );
  
  rd_en_fifo_q    <=   rd_en_fifo1  ;--or
                      -- rd_en_fifo3  or  rd_en_fifo4;
         
U5: fifo1
  PORT MAP (
    rst => rst_esb,
    wr_clk => clk_125_esb,
    rd_clk => tx_clk,
    din   => DIN_ESB_s_pul,
    wr_en => wr_en_fifo,
    rd_en => rd_en_fifo_q,
    dout  => din_Esb_tx2,
    full  => full,
    overflow => overflow,
    empty => empty,
    valid => valid,
	 underflow=> underflow,
    rd_data_count => rd_data_count,
    wr_data_count => wr_data_count
  );



U6: pulse_dist
       port map(clk       =>clk_100,
					 reset_in  =>rst_esb,
		          enable_ref=>enable_ref,
					 enable_rf1=>enable_rf2,
					 enable_rf2=>enable_rf3,
					 enable_rf3=>enable_rf4,
					 enable_rf4=>enable_rf5,
					 enable_rf5=>enable_rf6,
					 enable_rf6=>enable_rf7,
					 enable_rf7=>enable_rf8,
					 enable_rf8=>enable_rf8,
		             enable_trp=>enable_rf1,
					 beam_ini_gap => beam_ini_gap,
					 beam_hop_gap => beam_hop_gap,
					  PRT            =>           PRT1,     --- 100111000100000 -- 200 X"00004E20" ,--
					  P_W_TRP        =>           P_W_TRP1      ,
					  start_trp      =>           start_trp1    ,
					 
 					  P_W_RF1        =>           F_P_W_RF1,   --X"0CB2" , -- 08CA   ,    --100011001010 -- 22.5
					  start_RF1      =>           F_start_RF1    ,   -- X"000005DC" ,-- 1010101111100  -- 55
					  P_W_RF2        =>           F_P_W_RF2  , --X"109A",-- 0CB2  ,     -- 110010110010  -- 32.5
					  start_RF2      =>           F_start_RF2   ,  --X"000003E8",-- --  1001110001000 -- 50
					  P_W_RF3        =>           F_P_W_RF3  ,-- X"1388",-- 0fa0  ,   -- 111110100000  --40
					  start_RF3      =>           F_start_RF3   ,   -- X"00002EE0", ---- 15000
					  P_W_RF4        =>           F_P_W_RF4     ,
					  start_RF4      =>           F_start_RF4   ,
					  P_W_RF5        =>           F_P_W_RF5     ,
					  start_RF5      =>           F_start_RF5   ,
					  P_W_RF6        =>           F_P_W_RF6     ,
					  start_RF6      =>           F_start_RF6   ,
					  P_W_RF7        =>           F_P_W_RF7     ,
					  start_RF7      =>           F_start_RF7   ,
					  P_W_RF8        =>           F_P_W_RF8      ,
					  start_RF8      =>           F_start_RF8    ,
					  rf_p           =>           F_rf_p         ,
					  trp_p          =>           strp_p);


 rf_p  <=  F_rf_p;
 
 pw_pre_select    <=    P_W_TRP1;
 pw_rf_pulse 		<=	   F_P_W_RF1;
  pw_rf_pulse_v 		<=	   F_P_W_RF2;

 pw_data_wind		<=		F_P_W_RF3;
 pw_beam_ini		<= 	F_P_W_RF4;
 pw_beam_hop		<=  	F_P_W_RF5;               
 
 
 
 u7: DUT_signal_modle
      port map (
 
						clk  					    =>         clk_125_esb				   ,
						clk_100  			    =>         clk_100,
                  reset					    =>         rst_esb				      ,
                  en_monitor_enable	    =>         en_monitor_enable	      ,
                  val_monitor_enable	 =>         val_monitor_enable	   ,
                  en_PSU_On				 =>         en_PSU_On				   ,
                  val_PSU_ON				 =>         val_PSU_ON				   ,
                  en_PSU_off				 =>         en_PSU_off				   ,
                  val_psu_off			    =>         val_psu_off			      ,
                  en_Self_monitor_txd	 =>         en_Self_monitor_txd	   ,
                  val_self_monitor_txd  =>         val_self_monitor_txd    ,
                  monitor_enable		    =>         monitor_enable_sig		      ,
                  trm_psu_on				 =>         trm_psu_on				   ,
                  trm_psu_off			    =>         trm_psu_off			      ,
                  self_monitor_txd		 =>         self_monitor_txd		   );
                                                                           
 U8 :  pcpu_gen port map( 
            clk            =>  CLK_100,
            reset_in          =>  rst_esb,
            reset_enable     =>  gen_pcpu_mod,
            reset_out      =>  PCPU100u_sig    );          
 U9 :  pcpu_gen port map( 
                       clk            =>  CLK_100,
                       reset_in          =>  rst_esb,
                       reset_enable     =>  gen_pcpu_mod2,
                       reset_out      =>  PCPU100u_sig2    );                                                                          
 
end architecture beh;



	  
	  
	   
	
   

  


