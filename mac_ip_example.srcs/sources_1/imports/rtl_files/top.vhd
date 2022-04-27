
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USe IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;


entity top is
port(       glbl_rst             : in std_logic;
            clk_in_p		     : in std_logic;
	    	clk_in_n		     : in std_logic;

		    sma_clk_p            : in std_logic;
		    sma_clk_n            : in std_logic;
      
	    	phy_resetn           : out std_logic;
            mdio                 : inout std_logic;
            mdc                  : out std_logic;
            rgmii_txd            : out std_logic_vector(3 downto 0);
            rgmii_tx_ctl         : out std_logic;
            rgmii_txc            : out std_logic;
            rgmii_rxd            : in  std_logic_vector(3 downto 0);
            rgmii_rx_ctl         : in  std_logic;
            rgmii_rxc            : in  std_logic;

		    TX_UT_p       	     :  out STD_LOGIC;
            RX_UT_p              :  in  STD_LOGIC_vector(3 downto 0);
            
            PCPU100u_DUT         : out std_logic_vector(3 downto 0);
            PCPU100u_DUTq        : out std_logic_vector(3 downto 0);
            PCPU_status          : in std_logic_Vector(3 downto 0);
            
		    Monitor_enable       : out std_logic_vector(3 downto 0);            
            
	        DUT_RESET_P          :  out std_logic;
		    TX_PRE_SEL_P         :  out std_logic;
            TX_RF_PULSE_P        :  out std_logic;	
		    TX_BEAM_INI_P        :  out std_logic;
	    	RX_DATA_WIN_P        :  out std_logic;
            TX_BEAM_HOP_P        :  out std_logic;
            TX_RF_PULSE_V        :  out std_logic;
            TX_Win_Pulse         :  out std_logic;      
            pna_copy_sig         :  out std_logic;
            pna_copy2_sig        :  out std_logic;
            
            
--		self_test_RX_UT               :  out std_logic;
		
--		self_test_Tx_ut               :  in  STD_LOGIC;
--	--	self_dout_test                :  out  std_logic;

--		TX_Win_Pulse                  :  out std_logic;

--		RX_Supply_Win                 :  OUT std_logic;
--		TRC_CLK_REF_P                 :  out std_logic;
		
--		pna_copy_sig                  :  out std_logic;
--		pna_copy2_sig                 :  out std_logic;
          
--		Monitor_TXD                   :  in  std_logic;   
     
--      TRM_PSU_ON                    :  out std_logic;  
--      TRM_PSU_OFF                   :  out std_logic;
--      TRIB_PDU_SYNC                 :  out std_logic;		
	 
	
		
		self_preselect                :  in  std_logic;  
		self_tx_pulse_h               :  in  std_logic;  
		self_data_window              :  in  std_logic;  
		self_beam_ini                 :  in  std_logic;  
		self_beam_hop                 :  in  std_logic;  
		
		self_test_reset               :  in  std_logic;  
		self_tx_pulse_v               :  in  std_logic;
    --   self_monitor_enable             : in std_logic_vector(3 downto 0);
       self_test_PCPU100u            : in std_logic_vector(7 downto 0)		
--		self_clk_ref3MHz              :  in  std_logic;  
--		self_monitor_txd              :  out std_logic;
--		self_monitor_enable           :  in  std_logic;  
--		self_trm_PSU_ON               :  in  std_logic;  
--		self_trm_PSU_OFF              :  in  std_logic;  
--		Self_PDU_SYNC                 :  in  std_logic  

   );
end top;

architecture Behavioral of top is

signal 	self_test_RX_UT               :   std_logic;
signal 	self_test_Tx_ut               :    STD_LOGIC;

--signal 	TX_Win_Pulse                  :   std_logic;


signal 	RX_Supply_Win                 :   std_logic;
signal 	TRC_CLK_REF_P                 :   std_logic;
--signal 	pna_copy_sig                  :   std_logic;
--signal 	pna_copy2_sig                 :   std_logic;
signal 	Monitor_TXD                   :   std_logic;   
signal   TRM_PSU_ON                    :  std_logic;  
signal   TRM_PSU_OFF                   :  std_logic;
signal   TRIB_PDU_SYNC                 :  std_logic;		
signal En_J146                         :  std_logic;
signal 	RE_U3_low                     :   std_logic;
signal 	DE_U3_HIGH                    :   std_logic;
signal 	direction4_1                  :   std_logic;
signal 	direction5_0                  :   std_logic;
signal 	direction6_1                  :   std_logic;
signal 	direction7_1                  :   std_logic;
signal 	direction8_1                  :   std_logic;
signal 	direction12_0                 :   std_logic;
signal 	direction13_1                 :   std_logic;
signal 	direction14_0                 :   std_logic;
signal 	direction15_0                 :   std_logic;
signal 	direction16_0                 :   std_logic;	
signal 	RE_U11_low                    :   std_logic;
signal 	DE_U11_HIGH                   :   std_logic;		
--signal 	self_preselect                :   std_logic;  
signal 	self_tx_pulse                 :   std_logic;  
--signal 	self_data_window              :   std_logic;  
--signal 	self_beam_ini                 :   std_logic;  
--signal 	self_beam_hop                 :   std_logic;  
--signal 	self_test_reset               :   std_logic;  
signal 	self_clk_ref3MHz              :   std_logic;  
signal 	self_monitor_txd              :  std_logic;
--signal 	self_monitor_enable           :  std_logic;  
signal 	self_trm_PSU_ON               :  std_logic;  
signal 	self_trm_PSU_OFF              :  std_logic;  
signal 	Self_PDU_SYNC                 :  std_logic ;

signal	   reset_dut1p          :   std_logic;
signal		reset_dut1n          :   std_logic;

	
component clk_wiz
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  CLK_OUT3          : out    std_logic;
  CLK_OUT4          : out    std_logic;

  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;



component eth_rgmii is
    port (
      -- asynchronous reset
      glbl_rst                      : in  std_logic;

      -- 200MHz clock input from board
      clk_in_p                      : in  std_logic;
      clk_in_n                      : in  std_logic;
      -- 125 MHz clock output from MMCM
     -- gtx_clk_bufg_out              : out std_logic;

      phy_resetn                    : out std_logic;
      clk_125, clk_100, clk_200   :  out std_logic;

      -- RGMII Interface
      ------------------
       tx_axis_fifo_tready        : out std_logic;
      rgmii_txd                     : out std_logic_vector(3 downto 0);
      rgmii_tx_ctl                  : out std_logic;
      rgmii_txc                     : out std_logic;
      rgmii_rxd                     : in  std_logic_vector(3 downto 0);
      rgmii_rx_ctl                  : in  std_logic;
      rgmii_rxc                     : in  std_logic;

      -- MDIO Interface
      -----------------
      mdio                          : inout std_logic;
      mdc                           : out std_logic;

   rx_axis_fifo_tvalid  :   out std_logic;
      rx_axis_fifo_tdata   : out  std_logic_vector(7 downto 0);
      rx_axis_fifo_tlast :  out std_logic;
    
     tx_axis_fifo_tvalid : in  std_logic;
     tx_axis_fifo_tdata    : in  std_logic_vector(7 downto 0);
     tx_axis_fifo_tlast : in  std_logic
   
    

    );
end component;

COMPONENT packet_rx is
port (data_mac : in std_logic_vector (7 downto 0);
      valid : in std_logic;
		clock : in std_logic;
		data_en  : out std_logic;
		new_pkt  : out  std_logic;
      wr_en_bram :  out std_logic;
		addr_bram_in : out std_logic_vector(6 downto 0);
		rst      : in std_logic;
		data_out : out std_logic_Vector(7 downto 0));
end COMPONENT packet_rx;

component tx_u is
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
			          TRP_p :  out std_logic;
                  DOUT_ESB  :  out STD_LOGIC;
			 self_dout_test :  out  std_logic;
                    LEN_UMC :  out STD_LOGIC_VECTOR(7 downto 0);
             Data_Valid_UMC :  out STD_LOGIC;
			           rf_p :  out std_logic_vector(7 downto 0);
			     reset_dut1 :  out std_logic;
			   PCPU100u_DUT : out std_logic_Vector(3 downto 0);
			  PCPU100u_dutq : out std_logic_Vector(3 downto 0); 
		   cmd_id_DUT_num_q : out std_logic_vector(3 downto 0);
			  format_recvr  :  out std_logic;	
				    rx_data :  out STD_LOGIC_VECTOR(7 downto 0);
			 monitor_enable :  out std_logic_vector(3 downto 0);    
				 trm_psu_on :  out std_logic;	
			   trm_psu_off	:  out std_logic;   
		   self_monitor_txd :  out std_logic;
			gen_preselect_pulse, gen_tx_pulse_pulse, 
			gen_datawindow_pulse, gen_beamini_pulse, 
			gen_beamhop_pulse, gen_clkref_pulse, gen_tx_pulse_pulse_v,
		    gen_pdusync_pulse :   out  std_logic;
		enable_pcpu_rd_status : out std_logic_Vector(3 downto 0);	
			  rx_sclk         : out std_logic; 
			  TRIB_PDU_SYNC :  out std_logic;		
			   rx_pkt_cmplt :  in  std_logic_vector(3 downto 0);
			gen_pcpu_test : out std_logic_Vector(7 downto 0);	
		gen_monitor_txd_pulse, gen_PSU_OFF_pulse,
		  gen_PSU_On_pulse ,  
		    gen_reset_pulse :  out  std_logic;
			gen_monitor_enable_pulse : out std_logic_vector(3 downto 0);		
			pw_pre_select, pw_rf_pulse, pw_data_wind,pw_rf_pulse_v,
			pw_beam_ini, pw_beam_hop  :  out  std_logic_vector(15 downto 0)
       );
end  component;

component UART_MAC_BRIDGE_TOP is
    Port (  RX_IN_p        : in  STD_LOGIC_vector(3 downto 0);
            RX_monitor     : in  STD_LOGIC;
              rx_sclk         : in std_logic; 
            format_recvr  :  in std_logic;
		   self_test_in   : in  std_logic;
		   clk_200        :  in std_logic;
           DOUT_UMC        : out STD_LOGIC_VECTOR (7 downto 0);
           Data_Valid_UMC  : out STD_LOGIC;
		   cmd_id_DUT_num_q : in std_logic_vector(3 downto 0);
           Rd_Req_UMC      : in  std_logic; 
           LEN_UMC         : out STD_LOGIC_VECTOR (7 downto 0);
			  frame_length    :  in std_logic_vector(7 downto 0);
           CLK_UMC         : in  std_logic;
           valid_dut       : in std_logic_vector(3 downto 0);
			  valid_Self_test :  in  std_logic;
           RST_UMC         : in  std_logic;
			  rx_pkt_cmplt     : out   std_logic_vector(3 downto 0)

           );

end component;

component Packet_TX is
    Port (
         valid_dut            : in std_logic;
			tx_start				   : in std_logic;
			clk 						: in  STD_LOGIC;									
			reset 					: in  STD_LOGIC;										
			mac_data_out_ready	: in std_logic;								
			mac_data_out_valid	: out std_logic;							
			mac_data_out_first	: out std_logic;							
			mac_data_out_last		: out std_logic;							
			mac_data_out			: out std_logic_vector (7 downto 0);	 
			wait_cmd             : out std_logic;
			packet_header_tx     : in std_logic_vector(0  to 87); 
         data_out,len         : in std_logic_vector(7 downto 0);
			rdx						: out std_logic			
			);
end component;

component trp_self_gen is
port(   clk,
        reset,
		  sob_fb,
		  valid              : in std_logic; 
		  sob_self_test,
		  data_valid_umc_sob  :out std_logic);
end component;
		
component signal_status_test is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_check : in  STD_LOGIC;
           signal_in : in  STD_LOGIC;
           valid_pkt : out  STD_LOGIC;
           status_val : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

component psu_status_test is
port(clk,reset,sob_fb,valid: in std_logic; sob_self_test,data_valid_umc_sob:out std_logic);
end component;

component reset_self_gen is
port(clk,reset,sob_fb,valid: in std_logic; sob_self_test,data_valid_umc_sob:out std_logic);
end component;

component reset_inter_sys is
port ( clk    : in std_logic;
         reset_out     : out std_logic);
end component;

signal Data_Valid_UMC_final : std_logic;
signal Data_Valid_UMCss : std_logic;

signal rf_p_s : std_logic_vector(7 downto 0):=X"00";
signal      uart_ch           :  std_logic;

type state_type is (IDLE,wait_here_tcp,wait_here2);
signal next_state						: state_type;
	
signal        TRP_p :   std_logic;
signal    Tx_C      : std_logic;
signal    sTx_C     : std_logic;

signal RX_C       : Std_logic;
signal data_out   : std_logic_Vector(7 downto 0);
signal din_valid  : std_logic;
signal rst        : std_logic;
signal rx_data    : std_logic_Vector(7 downto 0);
signal rx_data_rdy: std_logic;
signal valid_uart_st :  std_logic;

signal act_uart      :  std_logic:='0';
signal   rx_sclk     :  std_logic; 


signal valid_dut     : std_logic_vector(3 downto 0);
signal rd            : std_logic:='0';
signal rd1           : std_logic;
signal rd2           : std_logic;
signal DOUT_UMC,DOUT_UMC_final,LEN_UMC,len_umcq,LEN_UMC2,LEN_UMC3,len,
       len_final,len_finalzz, en_self_test_pcpu:std_logic_vector(7 downto 0);
signal DOUT_UMC1,DOUT_UMCq : std_logic_vector(7 downto 0);
signal Data_Valid_UMC      : std_logic:='0'; 
signal Data_Valid_UMC1,Data_Valid_UMCq  : std_logic:='0';
signal Data_Valid_UMC2    : std_logic;
signal Tx_start           : std_logic;

signal wait_cmd      : std_logic;
signal miso          : std_logic;
signal dout_spi      : std_logic;
signal slave_out     : std_logic;
signal mac_tx_tready_int	: std_logic;			
signal mac_rx_tdata			: std_logic_vector (7 downto 0);
signal mac_rx_tvalid			: std_logic;
signal mac_rx_tlast			: std_logic;
--signal clk_125			: std_logic;
signal mac_tx_tdata			: std_logic_vector (7 downto 0);
signal mac_tx_tvalid			: std_logic;
signal mac_tx_tready			: std_logic;
signal mac_rx_tready			: std_logic;
 
signal mac_tx_tlast			: std_logic;
signal packet_header_tx:std_logic_vector(0 to 87);
signal clk_125: std_logic;
signal clk_200: std_logic;
signal clk_100: std_logic;
signal clk_20: std_logic;
signal LOCKED: std_logic;
signal clk_10 : std_logic;
signal mac_tx_tfirst: std_logic;
signal clk_input  : std_logic;
SIGNAL new_pkt   :  std_logic;
signal addr_bram_in   :   std_logic_vector(6 downto 0);
signal wr_en_bram    :  std_logic_vector(0 downto 0);

signal data_valid_umc_clk :  std_logic;	
signal  start_bit_num   :   std_logic_vector(3 downto 0);
signal  word_length   :   std_logic_vector(7 downto 0);
signal  frame_length  :   std_logic_vector(7 downto 0);
 SIGNAL TX_BEAM_HOP   :  std_logic;
 SIGNAL TX_BEAM_INI   :  std_logic;
 SIGNAL RX_DATA_WIN   :  std_logic;
 SIGNAL TX_RF_PULSE   :  std_logic;
 SIGNAL TX_PRE_SEL    :  std_logic;
 SIGNAL DUT_RESET     :  std_logic;
 
 Signal test_tx_96    :  std_logic;
 SIgnal count_4mhz  	 :   std_logic_vector(4 downto 0) := (others => '0');
 Signal clk_4m      	 :   std_logic ;
 SIGNAL en_clk_4mhz :   std_logic ; 

 SIGNAL en_clk_195khz :   std_logic ; 
 SIGNAL count_195khz  :   std_logic_vector(11 downto 0) := (others => '0'); 
 SIGNAL clk_195k      :   std_logic ;
SIGNAL data_valid_UMC_preselect, gen_preselect_pkt, en_self_test_preselect,gen_Tx_Pulse_pkt_v,
data_valid_UMC_Tx_Pulse,  gen_Tx_Pulse_pkt, en_self_test_Tx_Pulse,en_self_test_Tx_Pulse_v,
en_self_test_data_window, gen_data_window_pkt, data_valid_UMC_data_window,
data_valid_UMC_beam_ini, gen_beam_ini_pkt, en_self_test_beam_ini,
en_self_test_beam_hop,gen_beam_hop_pkt, data_valid_UMC_beam_hop,
data_valid_UMC_clk_ref3MHz, gen_clk_ref3MHz_pkt, en_self_test_clk_ref3MHz,
data_valid_UMC_PDU_SYNC, gen_PDU_SYNC_pkt, en_self_test_PDU_SYNC,
en_self_test_reset, reset_self_test, data_valid_umc_reset,
 gen_Monitor_TXD : std_logic := '0';
SIGNAL   	pw_pre_select, pw_rf_pulse, pw_data_wind,pw_rf_pulse_v,
				pw_beam_ini, pw_beam_hop                     : std_logic_vector(15 downto 0);
				
signal   			  rx_pkt_cmplt     :    std_logic_vector(3 downto 0);
signal	   cmd_id_DUT_num_q :  std_logic_vector(3 downto 0);

	
SIGNAL         data_psu_off,
               data_pdu_sync,
					data_psu_on,
					data_clk_3m,
					data_beam_hop,
					data_beam_ini,
					data_data_win,
					data_tx_pulse, data_tx_pulse_v,pcpu_self_test,
               data_pre_Sel      : std_logic_vector(7 downto 0);  
	
		

SIGNAL  en_self_trm_PSU_ON, en_self_trm_PSU_OFF,
         en_self_Monitor_TXD  :  STD_LOGIC;
 signal  en_self_monitor_enable, gen_monitor_enable : std_logic_vector(3 downto 0);      
SIGNAL  data_valid_umc_trm_PSU_ON, data_valid_umc_trm_PSU_OFF    :  std_logic; 
type arr1 is array (0 to 3) of std_logic_vector(3 downto 0);
SIGNAL  data_valid_umc_monitor_enable	:	arr1;
signal sma_clkin : std_logic;
signal test_count : std_logic_Vector(3 downto 0):= X"0";	  
signal  valid_Self_test   :  std_logic;
SIGNAL gen_trm_psu_on, gen_trm_psu_off :     std_logic;
 
component tx_9_6K is
port ( clk          :   in std_logic;
       reset        :   in std_logic;

       valid        :   in  std_logic;
		 pw_select    :	in	std_logic_vector(15 downto 0);
		 default_data :   in  std_logic_vector(7 downto 0);
		
		 tx_out       :   out std_logic_vector(7 downto 0));
end component;


component psu_on_off_self_data is
port ( clk          :   in std_logic;
       reset        :   in std_logic;

       valid        :   in  std_logic;
		 pw_select    :	in	std_logic_vector(23 downto 0);
		 default_data :   in  std_logic_vector(7 downto 0);
		
		 tx_out       :   out std_logic_vector(7 downto 0));
end component;


 component mac_ip_example_design_clocks is
   port (
   -- clocks
   clk_in_p                   : in std_logic;
   clk_in_n                   : in std_logic;

   -- asynchronous resets
   glbl_rst                   : in std_logic;
   dcm_locked                 : out std_logic;

   -- clock outputs
   gtx_clk_bufg               : out std_logic;
   
   refclk_bufg                : out std_logic;
   s_axi_aclk                 : out std_logic
   );
   end component;

component pcpu_status_gen is
port (   clk          :   in std_logic;
         reset        :   in std_logic;
         valid        :   in  std_logic;
		 dut_num      :   in  std_logic_vector(7 downto 0);
		 PCPU_status  :   in  std_logic;
		 valid_out    :   out std_logic;
		 tx_out       :   out std_logic_vector(7 downto 0));
end component;

signal      pcpu_status_dut1 : std_logic;
signal      pcpu_status_dut2 : std_logic;
signal      pcpu_status_dut3 : std_logic;
signal      pcpu_status_dut4 : std_logic;

signal enable_pcpu_rd_status : std_logic_vector(3 downto 0);
signal        data_pcpu_dut1 : std_logic_vector(7 downto 0);
signal        data_pcpu_dut2 : std_logic_vector(7 downto 0);
signal        data_pcpu_dut3 : std_logic_vector(7 downto 0);
signal        data_pcpu_dut4 : std_logic_vector(7 downto 0);
signal  format_recvr   : std_logic;
 
begin

  clk_buf : IBUFDS
  port map
   (O  => sma_clkin,
    I  => sma_clk_p,
    IB => sma_clk_n);

process(sma_clkin)
begin
if rising_edge(sma_clkin) then
test_count <= test_count + '1';
end if;
end process;

TRC_CLK_REF_P  <=  clk_4m; 
TRIB_PDU_SYNC  <=  clk_195k;
  
-- TX_UT_p           <=    sTX_c;       
 TX_PRE_SEL_P      <=   not TX_PRE_SEL;
 TX_RF_PULSE_P     <=    TX_RF_PULSE; 
 RX_DATA_WIN_P     <=    RX_DATA_WIN; 
 TX_BEAM_INI_P     <=    TX_BEAM_INI; 
 TX_BEAM_HOP_P     <=    TX_BEAM_HOP; 

TX_PRE_SEL    <= TRP_p;-- rf_p_s(1);
TX_RF_PULSE   <=  rf_p_s(0);--TRP_p;
TX_RF_PULSE_V   <= rf_p_s(1);-- rf_p_s(0);
RX_DATA_WIN   <= rf_p_s(2);
TX_BEAM_INI   <= not rf_p_s(3);
TX_BEAM_HOP   <= not rf_p_s(4);

TX_Win_Pulse   <= rf_p_s(5);   ---to pna
pna_copy_sig   <=  rf_p_s(5); 
pna_copy2_sig  <=  rf_p_s(5);

RX_Supply_Win  <= rf_p_s(2);


----TRIG_Pulse_5 <= rf_p_s(7);
	
--TX_Win_Pulse   <= rf_p_s(0);
--TX_BEAM_INI   <= not rf_p_s(1);
--RX_DATA_WIN   <= rf_p_s(4);
--TX_RF_PULSE   <= rf_p_s(3);
--TX_PRE_SEL    <= not rf_p_s(1);
--TX_BEAM_HOP   <= not rf_p_s(1);
--RX_Supply_Win  <= rf_p_s(2);		
 
 
 -- Monitor_enable <= '0';  

En_J146         <=    '0';   
RE_U3_low       <=    '0';
DE_U3_HIGH      <=    '0';
direction4_1    <=    '1';
direction5_0    <=    '0';
direction6_1    <=    '1';
direction7_1    <=    '1'; 
direction8_1    <=    '1'; 

direction12_0    <=   '0';
direction13_1    <=   '1';
direction14_0    <=   '0';
direction15_0    <=   '0';
direction16_0    <=   '0';

RE_U11_low       <=    '1';
DE_U11_HIGH      <=    '1';

--TRM_PSU_ON       <=   rf_p_s(3); 
--TRM_PSU_OFF      <=   rf_p_s(2);
--TRIB_PDU_SYNC    <=   '0';



--U_00:  reset_inter_sys port map( 
--                                clk       =>  clk_125,
--										--  reset_in  =>  gen_reset_mod,
--										  reset_out =>  rst    );


--in_clk_buf : IBUFGDS
--  port map
--   (O  => clk_input,
--    I  => clk_in_p,
--    IB => clk_in_n); 





	 
U1: packet_rx port map
     (
      data_mac       => mac_rx_tdata,
      valid          => mac_rx_tvalid,
		clock          => clk_125,
		data_en        => din_valid,
		new_pkt        => new_pkt,
		wr_en_bram     => wr_en_bram(0),
		addr_bram_in   => addr_bram_in,
		rst            => glbl_rst,
		data_out       => data_out
		);

U3: tx_u port map(  
              DIN_ESB_s     =>     data_out,
			  clk_input     =>     clk_200,
              valid_uart    =>     valid_dut,
              CLK_125_ESB   =>     clk_125,
              clk_20        =>     clk_20,
              RST_ESB       =>     glbl_rst,
			  addr_data_in  =>     addr_bram_in,
			  wr_en_bram    =>     wr_en_bram,
              DIN_VALID_ESB =>     din_valid,
              DOUT_ESB      =>     TX_UT_p  ,
			  clk_100       =>     clk_100,
			  new_pkt       =>     new_pkt,
			 frame_length   =>     frame_length,
             Rd_Req_UMC     =>     Rd, 
             LEN_UMC        =>     LEN_UMC2,
             Data_Valid_UMC =>     Data_Valid_UMC2,
             rf_p	        =>     rf_p_s,
             uart_ch        =>     uart_ch,
           cmd_id_DUT_num_q => cmd_id_DUT_num_q,
			 rx_data        =>     rx_data,
			 reset_dut1     =>     DUT_RESET_P,
			  self_test_rx  =>  valid_Self_test,
			 self_dout_test => self_test_RX_UT,
		  monitor_enable    =>    Monitor_enable,
		  trm_psu_on		=>    TRM_PSU_ON   ,
		   PCPU100u_DUT     =>     PCPU100u_DUT,
		   PCPU100u_DUTq    =>    PCPU100u_DUTq,
		           TRP_p    =>     TRP_p,
		           rx_sclk  =>    rx_sclk,
		            format_recvr   =>  format_recvr,
		       enable_pcpu_rd_status   =>  enable_pcpu_rd_status,
			   trm_psu_off			   =>    TRM_PSU_OFF  ,
				TRIB_PDU_SYNC          =>    open,
				en_clk_4mhz            =>    en_clk_4mhz,
				en_clk_195khz          =>    en_clk_195khz,
				self_monitor_txd	   =>    self_monitor_txd,
				gen_preselect_pulse    =>	  en_self_test_preselect,
				gen_tx_pulse_pulse     =>    en_self_test_Tx_Pulse,
				gen_tx_pulse_pulse_v   => en_self_test_Tx_Pulse_v,
				gen_datawindow_pulse   =>    en_self_test_data_window,
				gen_beamini_pulse      =>    en_self_test_beam_ini,
				gen_beamhop_pulse      =>    en_self_test_beam_hop,
                gen_clkref_pulse       =>   en_self_test_clk_ref3MHz,
				gen_pdusync_pulse      =>   en_self_test_PDU_SYNC,
				gen_monitor_txd_pulse  =>   en_self_Monitor_TXD,
			    gen_reset_pulse        =>   en_self_test_reset,
			    gen_pcpu_test          =>   en_self_test_pcpu,
			  gen_PSU_OFF_pulse        =>  en_self_trm_PSU_OFF,
			  gen_PSU_On_pulse         =>  en_self_trm_PSU_ON,
              gen_monitor_enable_pulse =>  en_self_monitor_enable,
			  pw_pre_select			   =>   pw_pre_select,
			  pw_rf_pulse              =>   pw_rf_pulse  ,
			  pw_rf_pulse_v            =>  pw_rf_pulse_v,
			  pw_data_wind             =>   pw_data_wind ,
			  pw_beam_ini              =>   pw_beam_ini  ,
			  pw_beam_hop              =>   pw_beam_hop,
                  rx_pkt_cmplt         =>   rx_pkt_cmplt			  
			  

);
	  

U4: UART_MAC_BRIDGE_TOP port map(
	                   RX_IN_p          => RX_UT_p,
							 RX_monitor       => Monitor_TXD, --RX_UT_p,
							 self_test_in     => self_test_Tx_ut,
							 frame_length     => frame_length,
							 clk_200          => clk_200,
							 cmd_id_DUT_num_q => cmd_id_DUT_num_q,
	                   DOUT_UMC         => DOUT_UMC,
	                   Data_Valid_UMC   => Data_Valid_UMC1,
	                   Rd_Req_UMC       => rd,
	                   rx_sclk          => rx_sclk,
	                   LEN_UMC          => LEN_UMC,                            -----------#########$#$#$#$#$#$$$$$$$$$$$$$$4
	                   CLK_UMC          => clk_125,
	                   valid_dut        => valid_dut , 
	                   format_recvr   =>  format_recvr,
                      valid_Self_test  =>    valid_Self_test,							 -----------------##############################################################################################-----------------
                      RST_UMC          => glbl_rst  ,
                      rx_pkt_cmplt => rx_pkt_cmplt							 );


	 
U5: Packet_TX PORT MAP (
          tx_start 			   => tx_start,
          valid_dut           =>valid_dut(0),
          clk 						=> clk_125,
          reset 					=> glbl_rst,
          mac_data_out_ready 	=> mac_tx_tready,
          mac_data_out_valid 	=> mac_tx_tvalid,
          mac_data_out_first 	=> mac_tx_tfirst,
          mac_data_out_last 	=> mac_tx_tlast,
          mac_data_out 			=> mac_tx_tdata,
			 wait_cmd            =>wait_cmd,
			 packet_header_tx		=>packet_header_tx,
			 data_out            =>DOUT_UMC_final,
			 len                 =>len_finalzz,
			 rdx                 =>rd
       );
		 
		 
 mac1 : eth_rgmii
               Port map( 
                      -- System controls
                      ------------------
                      glbl_rst                => glbl_rst,
                     clk_in_p           => clk_in_p,         
                  clk_in_n           => clk_in_n,       
                  ---LOCKED              => LOCKED,     
                  mdio=>mdio,
                  mdc  =>mdc, 
                      -- MAC Transmitter (AXI-S) Interface
                      ---------------------------------------------
                  --    clk_125      => clk_125,
                      tx_axis_fifo_tdata      => mac_tx_tdata, --mac_tx_tdata,
                      tx_axis_fifo_tvalid     =>mac_tx_tvalid, -- mac_tx_tvalid,
                      --mac_tx_tready     => mac_tx_tready,
                      tx_axis_fifo_tlast      =>mac_tx_tlast,-- mac_tx_tlast,
                      tx_axis_fifo_tready  => mac_tx_tready,
                      -- MAC Receiver (AXI-S) Interface
                      ------------------------------------------
                      --clk_125      => clk_125,
                      rx_axis_fifo_tdata      => mac_rx_tdata, --mac_rx_tdata,
                      rx_axis_fifo_tvalid     => mac_rx_tvalid,-- mac_rx_tvalid,
                  --    mac_rx_tready     => mac_rx_tready,
                      rx_axis_fifo_tlast      =>mac_rx_tlast,-- mac_rx_tlast,
                       clk_125 =>clk_125, 
                       clk_100 =>clk_100 ,
                       clk_200 =>clk_200,
                              
                      -- RGMII Interface
                      -----------------     
                      phy_resetn        => phy_resetn,
                      rgmii_txd    =>   rgmii_txd   ,
                      rgmii_tx_ctl =>   rgmii_tx_ctl,
                      rgmii_txc    =>   rgmii_txc   ,
                      rgmii_rxd    =>   rgmii_rxd   ,
                      rgmii_rx_ctl =>   rgmii_rx_ctl,
                      rgmii_rxc    =>   rgmii_rxc   
                      
              
                      
                     );



 mac_rx_tready<='1';

tx_proc_combinatorial1:process(clk_125,glbl_rst,Data_Valid_UMC_final)--)		data_valid_umc1
   begin
	if(glbl_rst='1')then		            
			next_state <= IDLE;	
		   len_finalzz<=(others=>'0');						
	elsif(clk_125='1' and clk_125'event)then	
		case next_state is
			when IDLE =>
			     tx_start <= '0';
			     len_finalzz<=(others=>'0');						
				if (Data_Valid_UMC_final='1') then
				   tx_start <= '1';
				   len_finalzz<=len_final;
				   next_state <= wait_here_tcp;
				end if;

			when wait_here_tcp=>
						
						tx_start <= '1';
			         next_state <= wait_here2;

			when wait_here2=>
			      tx_start <= '0';	
               if(wait_cmd='0')then
					tx_start <= '0';
					next_state <= IDLE;
					end if;

    when others=>null;						
		end case;
		end if;
	end process;
	


	 process(clk_125) 
begin
if rising_edge(clk_125) then
  if (gen_trm_psu_on='1' ) then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_psu_on;
	 len_final<=X"25";
  
	 
	  elsif  (gen_trm_psu_OFF='1' ) then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_psu_off;
	 len_final<=X"25";
	 
	
	 
	 
	
	 
--	  elsif  (gen_monitor_txd='1' and data_valid_umc_Monitor_TXD=X"1") then
--	  data_valid_umc_final <=  '1'; 
--    DOUT_UMC_final<=X"B7";
--	 len_final<=X"25";
	 
--	 elsif  (gen_monitor_txd='1' and data_valid_umc_Monitor_TXD =X"2") then
--	  data_valid_umc_final <=  '1'; 
--    DOUT_UMC_final<=X"B6";
--	 len_final<=X"25";
	 
	  elsif  (reset_self_test = '1') then
    data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=X"58";
	 len_final<=X"25";
	 
	 elsif  (pcpu_self_test(0) = '1') then
         data_valid_umc_final <=  '1'; 
         DOUT_UMC_final<=X"71";
          len_final<=X"25";
	 
    elsif  (pcpu_self_test(1) = '1') then
         data_valid_umc_final <=  '1'; 
         DOUT_UMC_final<=X"72";
          len_final<=X"25";	 
   
      elsif  (pcpu_self_test(2) = '1') then
               data_valid_umc_final <=  '1'; 
               DOUT_UMC_final<=X"73";
                len_final<=X"25"; 
      
       elsif  (pcpu_self_test(3) = '1') then
            data_valid_umc_final <=  '1'; 
            DOUT_UMC_final<=X"74";
             len_final<=X"25";      
    elsif  (pcpu_self_test(4) = '1') then
           data_valid_umc_final <=  '1'; 
           DOUT_UMC_final<=X"75";
            len_final<=X"25";     
    elsif  (pcpu_self_test(5) = '1') then
            data_valid_umc_final <=  '1'; 
            DOUT_UMC_final<=X"76";
             len_final<=X"25";  
     elsif  (pcpu_self_test(6) = '1') then
           data_valid_umc_final <=  '1'; 
           DOUT_UMC_final<=X"77";
            len_final<=X"25";     
                      
    elsif  (pcpu_self_test(7) = '1') then
            data_valid_umc_final <=  '1'; 
            DOUT_UMC_final<=X"78";
             len_final<=X"25";         
    
    
                                                                      
	 
	 elsif  (gen_preselect_pkt = '1') then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_pre_Sel;
	 len_final<=X"25";
	 
--	  elsif  (gen_PDU_SYNC_pkt = '1') then
--    data_valid_umc_final <=  '1'; 
--    DOUT_UMC_final<=data_pdu_sync;
--	 len_final<=X"25";
	 
	  
	
	 elsif  (gen_clk_ref3MHz_pkt = '1') then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_clk_3m;
	 len_final<=X"25";

	 elsif  (gen_beam_ini_pkt = '1') then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_beam_ini;
	 len_final<=X"25";
	 
	  elsif  (gen_beam_hop_pkt = '1') then
    data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_beam_hop;
	 len_final<=X"25";
	 
	 elsif  (gen_Tx_Pulse_pkt = '1') then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_tx_pulse;
	 len_final    <=X"25";	 
	
	elsif  (gen_Tx_Pulse_pkt_v = '1') then
           data_valid_umc_final <=  '1'; 
         DOUT_UMC_final<=data_tx_pulse_v;
          len_final    <=X"25";     
	 
	  elsif  (gen_data_window_pkt = '1') then
	  data_valid_umc_final <=  '1'; 
    DOUT_UMC_final<=data_data_win;
	 len_final<=X"25";
 
     elsif pcpu_status_dut1 = '1' then
        data_valid_umc_final <=  '1'; 
        DOUT_UMC_final       <=  data_pcpu_dut1;
         len_final           <=  X"25";
  
      elsif pcpu_status_dut2 = '1' then
            data_valid_umc_final <=  '1'; 
            DOUT_UMC_final       <=  data_pcpu_dut2;
             len_final           <=  X"25";       
 
     
     elsif pcpu_status_dut3 = '1' then
       data_valid_umc_final <=  '1'; 
       DOUT_UMC_final       <=  data_pcpu_dut3;
        len_final           <=  X"25";
	    
	  elsif pcpu_status_dut4 = '1' then
       data_valid_umc_final <=  '1'; 
       DOUT_UMC_final       <=  data_pcpu_dut4;
        len_final           <=  X"25";					
	
	else
   	data_valid_umc_final <=  data_valid_umcq; 
    DOUT_UMC_final<=DOUT_UMCq;
	 len_final<=len_umcq;
	 end if;
end if;
end process;

data_valid_umcq   <=  	data_valid_umc1; -- when (uart_ch = '1' ) else
                        --data_valid_umc2;
	
DOUT_UMCq   <=  	DOUT_UMC ;--when (uart_ch = '1' ) else
                        --rx_data;	
len_umcq   <=  	len_umc;-- when (uart_ch = '1' ) else
                       -- len_umc2;
	


	


process(clk_125) 
begin
if rising_edge(clk_125) then
 if en_clk_4mhz = '1' then
 count_4mhz  <= count_4mhz  + '1';
 else
  count_4mhz  <= (others => '0');
end if;
end if;
end process;

process(clk_125) 
begin
if rising_edge(clk_125) then
  if count_4mhz  < "10000" then
  clk_4m    <=   '0';
  else
  clk_4m    <=   '1';
  end if;
 end if;
end process; 
 

 
process(clk_125) 
begin
if rising_edge(clk_125) then
 if en_clk_195khz = '1' then
   if count_195khz <= X"280" then
    count_195khz  <= count_195khz  + '1';
   else
    count_195khz  <=  (others => '0');
   end if;
 else
     count_195khz  <=  (others => '0');
 end if;
end if;
end process;

process(clk_125) 
begin
if rising_edge(clk_125) then
  if count_195khz  < X"23f" then
  clk_195k    <=   '0';
  else
  clk_195k    <=   '1';
  end if;
 end if;
end process; 
 


--trm_PSU_ON_dut: psu_status_test port map (
--         clk 		        =>            clk_125,
--         reset 		     =>               glbl_rst,
--			sob_fb  		  =>				  self_trm_PSU_ON,
--         valid         =>             en_self_trm_PSU_ON,
--		   sob_self_test  		  => 				  gen_trm_PSU_ON,
--			data_valid_umc_sob 		  =>			  data_valid_umc_trm_PSU_ON
--									  );


--trm_PSU_OFF_dut: psu_status_test port map (
--         clk 		        =>            clk_125,
--         reset 		     =>               glbl_rst,
--			sob_fb  		  =>				  self_trm_PSU_OFF,
--         valid         =>             en_self_trm_PSU_OFF,
--		   sob_self_test  		  =>				  gen_trm_PSU_Off,
--			data_valid_umc_sob 		  =>			  data_valid_umc_trm_PSU_OFF
--			);



--me_st: for i in 0 to 3 generate 
--monitor_enable_dut: signal_status_test port map (
--         clk 		        =>            clk_125,
--         reset 		     =>               glbl_rst,
--	  signal_in  		  =>			self_monitor_enable(i),
--         en_check         =>             en_self_monitor_enable(i),
--		   valid_pkt  		  =>			  gen_monitor_enable(i),
--			status_val 		  =>			  data_valid_umc_monitor_enable(i));
-- end generate me_st;

--monitor_txd_dut: signal_status_test port map (
--         clk 		        =>            clk_125,
--         reset 		     =>               glbl_rst,
--			signal_in  		  =>				  Monitor_TXD,
--         en_check         =>             en_self_Monitor_TXD,
--			valid_pkt  		  =>			  gen_monitor_txd,
--			status_val 		  =>			  data_valid_umc_Monitor_TXD);



									  
 
reset_dut: reset_self_gen port map 
            (             clk      => clk_125,
                    reset    => glbl_rst,
                    sob_fb   =>  self_test_reset,
                    valid    => en_self_test_reset,
                    sob_self_test  =>  reset_self_test,
                    data_valid_umc_sob =>   data_valid_umc_reset 
  );

pcpu_comp: for i in 0 to 7 generate 
begin
pcpu_st: reset_self_gen port map
     (           clk      =>  clk_125,
                 reset    =>  glbl_rst,
                 sob_fb   =>  self_test_PCPU100u(i),
                 valid    =>  en_self_test_pcpu(i),
           sob_self_test  => pcpu_self_test(i),
       data_valid_umc_sob => open);
  end generate pcpu_comp;         






pre_select_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_preselect,
                  valid  					=>      en_self_test_preselect,           
                  sob_self_test			=>      gen_preselect_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_preselect);





--PDU_SYNC_DUT: trp_self_gen port map (

--						clk						=>      clk_125,
--                  reset 					=>      glbl_rst,
--                  sob_fb					=>      Self_PDU_SYNC,
--                  valid  					=>      en_self_test_PDU_SYNC,           
--                  sob_self_test			=>      gen_PDU_SYNC_pkt,
--                  data_valid_umc_sob	=>      data_valid_UMC_PDU_SYNC);


clk_ref_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_clk_ref3MHz,
                  valid  					=>      en_self_test_clk_ref3MHz,           
                  sob_self_test			=>      gen_clk_ref3MHz_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_clk_ref3MHz);

beam_ini_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_beam_ini,
                  valid  					=>      en_self_test_beam_ini,           
                  sob_self_test			=>      gen_beam_ini_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_beam_ini);




beam_hop_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_beam_hop,
                  valid  					=>      en_self_test_beam_hop,           
                  sob_self_test			=>      gen_beam_hop_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_beam_hop);


Tx_Pulse_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_Tx_Pulse_h,
                  valid  					=>      en_self_test_Tx_Pulse,           
                  sob_self_test			=>      gen_Tx_Pulse_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_Tx_Pulse);

Tx_Pulse_DUT2: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_Tx_Pulse_v,
                  valid  					=>      en_self_test_Tx_Pulse_v,           
                  sob_self_test			=>      gen_Tx_Pulse_pkt_v,
                  data_valid_umc_sob	=>      open);
						
data_win_DUT: trp_self_gen port map (

						clk						=>      clk_125,
                  reset 					=>      glbl_rst,
                  sob_fb					=>      self_data_window,
                  valid  					=>      en_self_test_data_window,           
                  sob_self_test			=>      gen_data_window_pkt,
                  data_valid_umc_sob	=>      data_valid_UMC_data_window);						



ud1_pre_sel: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_preselect_pkt,
               pw_select       =>    pw_pre_select,
               default_data    =>    X"51",
               tx_out          =>    data_pre_Sel);

ud2_rf_pul: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_Tx_Pulse_pkt,
               pw_select       =>    pw_rf_pulse,
               default_data    =>    X"52",
               tx_out          =>    data_tx_pulse);
					
ud3_rf_pul: tx_9_6K port map
                            (
                                   clk             =>    clk_125,
                              reset           =>    glbl_rst,
                              valid           =>    gen_Tx_Pulse_pkt_v,
                              pw_select       =>    pw_rf_pulse_v,
                              default_data    =>    X"56",
                              tx_out          =>    data_tx_pulse_v);
                              
pcpu_status_u1: pcpu_status_gen port map
             (
			   clk            =>    clk_125,
               reset          =>    glbl_rst,
               valid          =>    enable_pcpu_rd_status(0),
               dut_num        =>    X"01",
               pcpu_status    =>    pcpu_status(0),
               valid_out      =>    pcpu_status_dut1,
               tx_out         =>    data_pcpu_dut1);

pcpu_status_u2: pcpu_status_gen port map
             (
			   clk            =>    clk_125,
               reset          =>    glbl_rst,
               valid          =>    enable_pcpu_rd_status(1),
               dut_num        =>    X"02",
               pcpu_status    =>    pcpu_status(1),
               valid_out      =>    pcpu_status_dut2,
               tx_out         =>    data_pcpu_dut2);
pcpu_status_u3: pcpu_status_gen port map
             (
               clk            =>    clk_125,
               reset          =>    glbl_rst,
               valid          =>    enable_pcpu_rd_status(2),
               dut_num        =>    X"03",
               pcpu_status    =>    pcpu_status(2),
               valid_out      =>    pcpu_status_dut3,
               tx_out         =>    data_pcpu_dut3);  
                            
pcpu_status_u4: pcpu_status_gen port map
              (
                clk            =>    clk_125,
                reset          =>    glbl_rst,
                valid          =>    enable_pcpu_rd_status(3),
                dut_num        =>    X"04",
                pcpu_status    =>    pcpu_status(3),
                valid_out      =>    pcpu_status_dut4,
                tx_out         =>    data_pcpu_dut4
                );	
                				
ud3_data_win: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_data_window_pkt,
               pw_select       =>    pw_data_wind,
               default_data    =>    X"53",
               tx_out          =>    data_data_win);
					

ud4_beam_in: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_beam_ini_pkt,
               pw_select       =>    pw_beam_ini,
               default_data    =>    X"54",
               tx_out          =>    data_beam_ini);	
					
ud5_beam_hop: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_beam_hop_pkt,
               pw_select       =>    pw_beam_hop,
               default_data    =>    X"55",
               tx_out          =>    data_beam_hop);	
 
ud6_clk_3m: tx_9_6K port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_clk_ref3MHz_pkt,
               pw_select       =>    X"000D",
               default_data    =>    X"56",
               tx_out          =>    data_clk_3m);	
					
					
--ud7_pdu_syn: tx_9_6K port map
--             (
--					clk             =>    clk_125,
--               reset           =>    glbl_rst,
--               valid           =>    gen_PDU_SYNC_pkt,
--               pw_select       =>    X"0033",
--               default_data    =>    X"57",
--               tx_out          =>    data_pdu_sync);	
					
ud8_psu_on: psu_on_off_self_data port map
             (
					clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_trm_PSU_ON,
               pw_select       =>    X"989680",
               default_data    =>    X"B3",
               tx_out          =>    data_psu_on);	
ud9_psu_off: psu_on_off_self_data port map
             (
			   clk             =>    clk_125,
               reset           =>    glbl_rst,
               valid           =>    gen_trm_PSU_OFF,
               pw_select       =>    X"989680",
               default_data    =>    X"B5",
               tx_out          =>    data_psu_off);					

end Behavioral;

--OBUFDS_DUT_reset : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => DUT_RESET_P,                         
--       OB => DUT_RESET_N,                         
--       I  => DUT_RESET                                         
--    );
--		
--
  
--OBUFDS_TX_out : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TX_UT_p,                 
--       OB => TX_UT_n,                         
--       I  => TX_C                                                                               
--    );  
--
--
-- OBUFDS_pre_sel : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TX_PRE_SEL_P,                 
--       OB => TX_PRE_SEL_N,                         
--       I  => TX_PRE_SEL                                                                               
--    );
--
--
-- OBUFDS_rf_pulse : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TX_RF_PULSE_P,                 
--       OB => TX_RF_PULSE_N,                         
--       I  => TX_RF_PULSE                                                                               
--    );
--
--OBUFDS_data_win : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => RX_DATA_WIN_P,                 
--       OB => RX_DATA_WIN_N,                         
--       I  => RX_DATA_WIN                                                                               
--    );
--	 
--OBUFDS_beam_ini : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TX_BEAM_INI_P,                 
--       OB => TX_BEAM_INI_N,                         
--       I  => TX_BEAM_INI                                                                               
--    );	 
--	
--OBUFDS_beam_HOP : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TX_BEAM_HOP_P,                 
--       OB => TX_BEAM_HOP_N,                         
--       I  => TX_BEAM_HOP                                                                               
--    );	 
--	 
--
--OBUFDS_clk_REF : OBUFDS                                                                                       
--    generic map (                                                                                           
--       IOSTANDARD => "DEFAULT")                                                                             
--    port map (                                                                                              
--       O  => TRC_CLK_REF_P,                 
--       OB => TRC_CLK_REF_N,                         
--       I  => TRC_CLK_REF                                                                               
--    );