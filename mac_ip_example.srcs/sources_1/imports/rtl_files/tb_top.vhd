----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2017 10:04:55 AM
-- Design Name: 
-- Module Name: sim_top_def - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_top is
  
end tb_top;

architecture Behavioral of tb_top is
component TOP is
 port( clk_in_p		                  :in std_logic;
		clk_in_n		                  :in std_logic;
      
		phy_resetn            			: out std_logic;
      mdio                          : inout std_logic;
      mdc                           : out std_logic;
      gmii_txd                      : out std_logic_vector(7 downto 0);
      gmii_tx_en                    : out std_logic;
      gmii_tx_er                    : out std_logic;
      gmii_tx_clk                   : out std_logic;
      gmii_rxd                      : in  std_logic_vector(7 downto 0);
      gmii_rx_dv                    : in  std_logic;
      gmii_rx_er                    : in  std_logic;
      gmii_rx_clk                   : in  std_logic;
		
	
	   DUT_RESET_P                   :  out std_logic;
	
      RX_UT_p                       :  in  STD_LOGIC;
		self_test_RX_UT               :  out std_logic;
		
		TX_UT_p       					   :  out STD_LOGIC;
		self_test_Tx_ut               :  in  STD_LOGIC;
	--	self_dout_test                :  out  std_logic;
		TX_PRE_SEL_P                  :  out std_logic;
		TX_RF_PULSE_P                 :  out std_logic;
		TX_Win_Pulse                  :  out std_logic;
		RX_DATA_WIN_P                 :  out std_logic;
		TX_BEAM_INI_P                 :  out std_logic;
		TX_BEAM_HOP_P                 :  out std_logic;
		RX_Supply_Win                 :  OUT std_logic;
		TRC_CLK_REF_P                 :  out std_logic;
		
		Monitor_enable                :  out std_logic;          
		Monitor_TXD                   :  in  std_logic;   
     
      TRM_PSU_ON                    :  out std_logic;  
      TRM_PSU_OFF                   :  out std_logic;
      TRIB_PDU_SYNC                 :  out std_logic;		
	 
   	En_J146                       :  out std_logic;
		RE_U3_low                        :  out std_logic;
		DE_U3_HIGH                       :  out std_logic;
		
		direction4_1                  :  out std_logic;
		direction5_0                  :  out std_logic;
		direction6_1                  :  out std_logic;
		direction7_1                  :  out std_logic;
		direction8_1                  :  out std_logic;

		direction12_0                  :  out std_logic;
		direction13_1                  :  out std_logic;
		direction14_0                  :  out std_logic;
		direction15_0                  :  out std_logic;
		direction16_0                  :  out std_logic;	
 
 --     En_J146                       :  out std_logic;
		RE_U11_low                        :  out std_logic;
		DE_U11_HIGH                       :  out std_logic;		
		
		self_preselect                :  in  std_logic;  
		self_tx_pulse                 :  in  std_logic;  
		self_data_window              :  in  std_logic;  
		self_beam_ini                 :  in  std_logic;  
		self_beam_hop                 :  in  std_logic;  
		
		self_test_reset               :  in  std_logic;  
		self_clk_ref3MHz              :  in  std_logic;  
		self_monitor_txd              :  out std_logic;
		self_monitor_enable           :  in  std_logic;  
		self_trm_PSU_ON               :  in  std_logic;  
		self_trm_PSU_OFF              :  in  std_logic;  
		Self_PDU_SYNC                 :  in  std_logic  

   );
end component;


signal        TRIG_Pulse_1 : std_logic:='0';
signal	     TRIG_Pulse_2 : std_logic:='0';
signal	     TRIG_Pulse_3: std_logic:='0';
signal	     TRIG_Pulse_4: std_logic:='0';
signal	     TRIG_Pulse_5: std_logic:='0';
signal	     RF_Pulse_1    : std_logic:='0';
signal	     RF_Pulse_2: std_logic:='0';
signal	     RF_Pulse_3: std_logic:='0';
signal        clk_in_p   :  std_logic := '0';
signal        clk_in_n   :  std_logic := '1';



signal      self_preselect     :   std_logic; 
signal	   self_tx_pulse      :   std_logic; 
signal	   self_data_window   :   std_logic;
signal	   self_beam_ini      :   std_logic; 
signal	   self_beam_hop      :   std_logic; 
signal	   self_test_reset    :   std_logic; 
signal	   self_clk_ref3MHz   :   std_logic; 
signal	   self_monitor_txd    :  std_logic; 
signal      self_monitor_enable :  std_logic;
signal      self_trm_PSU_ON     :  std_logic; 
signal	   self_trm_PSU_OFF    :  std_logic; 
signal	   Self_PDU_SYNC       :  std_logic; 
signal      self_test_RX_UT	  :  std_logic; 
signal      self_test_Tx_ut	  :  std_logic; 







  ------------------------------------------------------------------------------------------------------------------
 


type data_typ is record
      data : bit_vector(7 downto 0);        -- data
      valid : bit;                          -- data_valid
      error : bit;                          -- data_error
  end record;
  type frame_of_data_typ is array (natural range <>) of data_typ;

  -- Tx Data, Data_valid and underrun record
  type mac_ip_frame_typ is record
      columns   : frame_of_data_typ(0 to 127 );-- data field
      bad_frame : boolean;                   -- does this frame contain an error?
  end record;
  type frame_typ_ary is array (natural range <>) of mac_ip_frame_typ;

  -----------------------------------
  -- testbench mode selection
  -----------------------------------
  -- the testbench hhas two modes of operation:
  --  - DEMO :=   In this mode frames are generated and checked by the testbench
  --              and looped back at the user side of the MAC.
  --  - BIST :=   In this mode the built in pattern generators and patttern
  --              checkers are used with the data looped back in the PHY domain.
  --constant TB_MODE                  : string := "BIST";
  constant TB_MODE                  : string := "DEMO";


  ------------------------------------------------------------------------------
  -- Stimulus - Frame data
  ------------------------------------------------------------------------------
  -- The following constant holds the stimulus for the testbench. It is
  -- an ordered array of frames, with frame 0 the first to be injected
  -- into the core transmit interface by the testbench.
  ------------------------------------------------------------------------------
  constant frame_data : frame_typ_ary := (
   -------------
   -- Frame 0
   -------------
    0          => (
      columns  => (
          0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Destination Address (DA)
           1      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           2      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           3      => ( DATA => X"33", VALID => '1', ERROR => '0'),
           4      => ( DATA => X"44", VALID => '1', ERROR => '0'),
           5      => ( DATA => X"55", VALID => '1', ERROR => '0'),
           6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Source Address (5A)
           7      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           8      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           9      => ( DATA => X"33", VALID => '1', ERROR => '0'),
          10      => ( DATA => X"44", VALID => '1', ERROR => '0'),
          11      => ( DATA => X"55", VALID => '1', ERROR => '0'),
          12      => ( DATA => X"88", VALID => '1', ERROR => '0'),
          13      => ( DATA => X"b6", VALID => '1', ERROR => '0'),     --  
           14      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
			  15      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
            16      => ( DATA => X"CC", VALID => '1', ERROR => '0'), --command
            17      => ( DATA => X"50", VALID => '1', ERROR => '0'), --  ENABLE  
           
			  18      => ( DATA => X"00", VALID => '1', ERROR => '0'), --    
            19      => ( DATA => X"00", VALID => '1', ERROR => '0'), --   
            20      => ( DATA => X"03", VALID => '1', ERROR => '0'), 
            21      => ( DATA => X"E8", VALID => '1', ERROR => '0'), --PRT 
           
			  22      => ( DATA => X"00", VALID => '1', ERROR => '0'),--  
			   23     => ( DATA => X"28", VALID => '1', ERROR => '0'),-- TRP PW
            
				24      => ( DATA => X"00", VALID => '1', ERROR => '0'), --  
            25      => ( DATA => X"14", VALID => '1', ERROR => '0'),   --  RF-1_PW
            
				26      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            27      => ( DATA => X"14", VALID => '1', ERROR => '0'),  --RF-2 PWW
           
			  28      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            29      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-3  PW
           
			   30     => ( DATA => X"00", VALID => '1', ERROR => '0'),
            31      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-4 PW
           
			  32      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            33      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-5 PW
           
			  34      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            35      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-6  PW
            
				36      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            37      => ( DATA => X"14", VALID => '1', ERROR => '0'),  --RF-7 PW
           
			  38      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            39      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-8 PW
         
			  40      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            41      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
			  42      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            43      => ( DATA => X"F4", VALID => '1', ERROR => '0'),  --ST trp
           
			  44      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            45      => ( DATA => X"00", VALID => '1', ERROR => '0'), --
			  46      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            47      => ( DATA => X"FE", VALID => '1', ERROR => '0'),  --ST RF1
				
            48      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            49      => ( DATA => X"00", VALID => '1', ERROR => '0'),--
				50      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            51      => ( DATA => X"FE", VALID => '1', ERROR => '0'), ------------ RF2
           
			  52      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            53      => ( DATA => X"00", VALID => '1', ERROR => '0'), --
			  54      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            55      => ( DATA => X"FE", VALID => '1', ERROR => '0'), ---####--- RF3
          
			   56      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            57      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            58      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            59      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf4
		
            60      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            61      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            62      => ( DATA => X"01", VALID => '1', ERROR => '0'),  -----
            63      => ( DATA => X"FE", VALID => '1', ERROR => '0'),--Rf-5
            
				64      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            65      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            66      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            67      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf-6
           
			   68      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            69      => ( DATA => X"00", VALID => '1', ERROR => '0'), ---####---
            70      => ( DATA => X"01", VALID => '1', ERROR => '0'),  ---
            71      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf-7
     
        	   72      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            73      => ( DATA => X"00", VALID => '1', ERROR => '0'),
				74      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            75      => ( DATA => X"01", VALID => '1', ERROR => '0'), 
				76      => ( DATA => X"76", VALID => '1', ERROR => '0'),
            77      => ( DATA => X"77", VALID => '1', ERROR => '0'),
				78      => ( DATA => X"78", VALID => '1', ERROR => '0'),
            79      => ( DATA => X"79", VALID => '1', ERROR => '0'), 
				-- rf-8
       others  => ( DATA => X"FE", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
            -------------
        -- Frame 1
        -------------
         1          => (
           columns  => (
              0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Destination Address (DA)
           1      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           2      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           3      => ( DATA => X"33", VALID => '1', ERROR => '0'),
           4      => ( DATA => X"44", VALID => '1', ERROR => '0'),
           5      => ( DATA => X"55", VALID => '1', ERROR => '0'),
           6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Source Address (5A)
           7      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           8      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           9      => ( DATA => X"33", VALID => '1', ERROR => '0'),
          10      => ( DATA => X"44", VALID => '1', ERROR => '0'),
          11      => ( DATA => X"55", VALID => '1', ERROR => '0'),
          12      => ( DATA => X"88", VALID => '1', ERROR => '0'),
          13      => ( DATA => X"b6", VALID => '1', ERROR => '0'),     --  
           14      => ( DATA => X"03", VALID => '1', ERROR => '0'),  --
			  15      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
            16      => ( DATA => X"00", VALID => '1', ERROR => '0'), --
            17      => ( DATA => X"10", VALID => '1', ERROR => '0'), --    
           
			  18      => ( DATA => X"CD", VALID => '1', ERROR => '0'), --       
            19      => ( DATA => X"FF", VALID => '1', ERROR => '0'), --   
            20      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            21      => ( DATA => X"00", VALID => '1', ERROR => '0'), --PRT 
           
			  22      => ( DATA => X"00", VALID => '1', ERROR => '0'),--  
			   23     => ( DATA => X"1F", VALID => '1', ERROR => '0'),-- TRP PW
            
				24      => ( DATA => X"00", VALID => '1', ERROR => '0'), --  
            25      => ( DATA => X"07", VALID => '1', ERROR => '0'),   --  RF-1_PW
            
				26      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            27      => ( DATA => X"07", VALID => '1', ERROR => '0'),  --RF-2 PWW
           
			  28      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            29      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-3  PW
           
			   30     => ( DATA => X"00", VALID => '1', ERROR => '0'),
            31      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-4 PW
           
			  32      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            33      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-5 PW
           
			  34      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            35      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-6  PW
            
				36      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            37      => ( DATA => X"07", VALID => '1', ERROR => '0'),  --RF-7 PW
           
			  38      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            39      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-8 PW
         
			  40      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            41      => ( DATA => X"07", VALID => '1', ERROR => '0'), 
			  
			  42      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            43      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --ST trp
			  44      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            45      => ( DATA => X"05", VALID => '1', ERROR => '0'), --
			  
			  46      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            47      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --ST RF1
            48      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            49      => ( DATA => X"05", VALID => '1', ERROR => '0'),--
				
				50      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            51      => ( DATA => X"00", VALID => '1', ERROR => '0'), ------------ RF2
			  52      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            53      => ( DATA => X"05", VALID => '1', ERROR => '0'), --
				
			  54      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            55      => ( DATA => X"00", VALID => '1', ERROR => '0'), ---####--- RF3
          
			   56      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            57      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            58      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            59      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf4
		
            60      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            61      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            62      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            63      => ( DATA => X"00", VALID => '1', ERROR => '0'),--Rf-5
            
				64      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            65      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            66      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            67      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf-6
           
			   68      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            69      => ( DATA => X"05", VALID => '1', ERROR => '0'), ---####---
            70      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            71      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf-7
     
        	   72      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            73      => ( DATA => X"05", VALID => '1', ERROR => '0'),
				74      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            75      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- rf-8
				76      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            77      => ( DATA => X"05", VALID => '1', ERROR => '0'),
				78      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            79      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            others  => ( DATA => X"00", VALID => '0', ERROR => '0')),
     
           -- No error in this frame
           bad_frame => false),
     
     
        -------------
        -- Frame 2
        -------------
         2          => (
          columns  => (
              0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Destination Address (DA)
           1      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           2      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           3      => ( DATA => X"33", VALID => '1', ERROR => '0'),
           4      => ( DATA => X"44", VALID => '1', ERROR => '0'),
           5      => ( DATA => X"55", VALID => '1', ERROR => '0'),
           6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Source Address (5A)
           7      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           8      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           9      => ( DATA => X"33", VALID => '1', ERROR => '0'),
          10      => ( DATA => X"44", VALID => '1', ERROR => '0'),
          11      => ( DATA => X"55", VALID => '1', ERROR => '0'),
          12      => ( DATA => X"88", VALID => '1', ERROR => '0'),
          13      => ( DATA => X"b6", VALID => '1', ERROR => '0'),     --  
           14      => ( DATA => X"01", VALID => '1', ERROR => '0'),  --
			  15      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
            16      => ( DATA => X"04", VALID => '1', ERROR => '0'), --
            17      => ( DATA => X"04", VALID => '1', ERROR => '0'), --    
           
			  18      => ( DATA => X"A5", VALID => '1', ERROR => '0'), --       
            19      => ( DATA => X"55", VALID => '1', ERROR => '0'), --   
            20      => ( DATA => X"55", VALID => '1', ERROR => '0'), 
            21      => ( DATA => X"55", VALID => '1', ERROR => '0'), --PRT 
           
			  22      => ( DATA => X"00", VALID => '1', ERROR => '0'),--  
			   23     => ( DATA => X"1F", VALID => '1', ERROR => '0'),-- TRP PW
            
				24      => ( DATA => X"00", VALID => '1', ERROR => '0'), --  
            25      => ( DATA => X"07", VALID => '1', ERROR => '0'),   --  RF-1_PW
            
				26      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            27      => ( DATA => X"07", VALID => '1', ERROR => '0'),  --RF-2 PWW
           
			  28      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            29      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-3  PW
           
			   30     => ( DATA => X"00", VALID => '1', ERROR => '0'),
            31      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-4 PW
           
			  32      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            33      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-5 PW
           
			  34      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            35      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-6  PW
            
				36      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            37      => ( DATA => X"07", VALID => '1', ERROR => '0'),  --RF-7 PW
           
			  38      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            39      => ( DATA => X"07", VALID => '1', ERROR => '0'), --RF-8 PW
         
			  40      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            41      => ( DATA => X"07", VALID => '1', ERROR => '0'), 
			  
			  42      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            43      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --ST trp
			  44      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            45      => ( DATA => X"05", VALID => '1', ERROR => '0'), --
			  
			  46      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            47      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --ST RF1
            48      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            49      => ( DATA => X"05", VALID => '1', ERROR => '0'),--
				
				50      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            51      => ( DATA => X"00", VALID => '1', ERROR => '0'), ------------ RF2
			  52      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            53      => ( DATA => X"05", VALID => '1', ERROR => '0'), --
				
			  54      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            55      => ( DATA => X"00", VALID => '1', ERROR => '0'), ---####--- RF3
          
			   56      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            57      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            58      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            59      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf4
		
            60      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            61      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            62      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            63      => ( DATA => X"00", VALID => '1', ERROR => '0'),--Rf-5
            
				64      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            65      => ( DATA => X"05", VALID => '1', ERROR => '0'),
            66      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            67      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf-6
           
			   68      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            69      => ( DATA => X"05", VALID => '1', ERROR => '0'), ---####---
            70      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            71      => ( DATA => X"00", VALID => '1', ERROR => '0'), --rf-7
     
        	   72      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            73      => ( DATA => X"05", VALID => '1', ERROR => '0'),
				74      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            75      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -- rf-8
				76      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            77      => ( DATA => X"05", VALID => '1', ERROR => '0'),
				78      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            79      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            others  => ( DATA => X"00", VALID => '0', ERROR => '0')),
     
            -- Error this frame
           bad_frame => false),
     
     
        -------------
        -- Frame 3
        -------------
        3          => (
           columns  => (
                  0      => ( DATA => X"DA", VALID => '1', ERROR => '0'), -- Destination Address (DA)
           1      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           2      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           3      => ( DATA => X"33", VALID => '1', ERROR => '0'),
           4      => ( DATA => X"44", VALID => '1', ERROR => '0'),
           5      => ( DATA => X"55", VALID => '1', ERROR => '0'),
           6      => ( DATA => X"5A", VALID => '1', ERROR => '0'), -- Source Address (5A)
           7      => ( DATA => X"11", VALID => '1', ERROR => '0'),
           8      => ( DATA => X"22", VALID => '1', ERROR => '0'),
           9      => ( DATA => X"33", VALID => '1', ERROR => '0'),
          10      => ( DATA => X"44", VALID => '1', ERROR => '0'),
          11      => ( DATA => X"55", VALID => '1', ERROR => '0'),
          12      => ( DATA => X"88", VALID => '1', ERROR => '0'),
          13      => ( DATA => X"b6", VALID => '1', ERROR => '0'),     --  
           14      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
			  15      => ( DATA => X"00", VALID => '1', ERROR => '0'),  --
            16      => ( DATA => X"05", VALID => '1', ERROR => '0'), --command
            17      => ( DATA => X"05", VALID => '1', ERROR => '0'), --  ENABLE  
           
			  18      => ( DATA => X"A5", VALID => '1', ERROR => '0'), --    
            19      => ( DATA => X"AA", VALID => '1', ERROR => '0'), --   
            20      => ( DATA => X"AA", VALID => '1', ERROR => '0'), 
            21      => ( DATA => X"55", VALID => '1', ERROR => '0'), --PRT 
           
			  22      => ( DATA => X"00", VALID => '1', ERROR => '0'),--  
			   23     => ( DATA => X"28", VALID => '1', ERROR => '0'),-- TRP PW
            
				24      => ( DATA => X"00", VALID => '1', ERROR => '0'), --  
            25      => ( DATA => X"14", VALID => '1', ERROR => '0'),   --  RF-1_PW
            
				26      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            27      => ( DATA => X"14", VALID => '1', ERROR => '0'),  --RF-2 PWW
           
			  28      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
            29      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-3  PW
           
			   30     => ( DATA => X"00", VALID => '1', ERROR => '0'),
            31      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-4 PW
           
			  32      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            33      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-5 PW
           
			  34      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            35      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-6  PW
            
				36      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            37      => ( DATA => X"14", VALID => '1', ERROR => '0'),  --RF-7 PW
           
			  38      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            39      => ( DATA => X"14", VALID => '1', ERROR => '0'), --RF-8 PW
         
			  40      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            41      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
			  42      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            43      => ( DATA => X"F4", VALID => '1', ERROR => '0'),  --ST trp
           
			  44      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            45      => ( DATA => X"00", VALID => '1', ERROR => '0'), --
			  46      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            47      => ( DATA => X"FE", VALID => '1', ERROR => '0'),  --ST RF1
				
            48      => ( DATA => X"00", VALID => '1', ERROR => '0'),  -----
            49      => ( DATA => X"00", VALID => '1', ERROR => '0'),--
				50      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            51      => ( DATA => X"FE", VALID => '1', ERROR => '0'), ------------ RF2
           
			  52      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            53      => ( DATA => X"00", VALID => '1', ERROR => '0'), --
			  54      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            55      => ( DATA => X"FE", VALID => '1', ERROR => '0'), ---####--- RF3
          
			   56      => ( DATA => X"00", VALID => '1', ERROR => '0'),  ---
            57      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            58      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            59      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf4
		
            60      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            61      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            62      => ( DATA => X"01", VALID => '1', ERROR => '0'),  -----
            63      => ( DATA => X"FE", VALID => '1', ERROR => '0'),--Rf-5
            
				64      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            65      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            66      => ( DATA => X"01", VALID => '1', ERROR => '0'),
            67      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf-6
           
			   68      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            69      => ( DATA => X"00", VALID => '1', ERROR => '0'), ---####---
            70      => ( DATA => X"01", VALID => '1', ERROR => '0'),  ---
            71      => ( DATA => X"FE", VALID => '1', ERROR => '0'), --rf-7
     
        	   72      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            73      => ( DATA => X"00", VALID => '1', ERROR => '0'),
				74      => ( DATA => X"00", VALID => '1', ERROR => '0'),
            75      => ( DATA => X"01", VALID => '1', ERROR => '0'),  -- rf-8
				76      => ( DATA => X"76", VALID => '1', ERROR => '0'),
            77      => ( DATA => X"77", VALID => '1', ERROR => '0'),
				78      => ( DATA => X"78", VALID => '1', ERROR => '0'),
            79      => ( DATA => X"79", VALID => '1', ERROR => '0'), 
            others  => ( DATA => X"FE", VALID => '0', ERROR => '0')),
     
            -- Error this frame
           bad_frame => false)
     );
            function calc_crc (data : in std_logic_vector;
                           fcs  : in std_logic_vector)
        return std_logic_vector is
      
          variable crc          : std_logic_vector(31 downto 0);
          variable crc_feedback : std_logic;
        begin
      
          crc := not fcs;
      
          for I in 0 to 7 loop
            crc_feedback      := crc(0) xor data(I);
      
            crc(4 downto 0)   := crc(5 downto 1);
            crc(5)            := crc(6)  xor crc_feedback;
            crc(7 downto 6)   := crc(8 downto 7);
            crc(8)            := crc(9)  xor crc_feedback;
            crc(9)            := crc(10) xor crc_feedback;
            crc(14 downto 10) := crc(15 downto 11);
            crc(15)           := crc(16) xor crc_feedback;
            crc(18 downto 16) := crc(19 downto 17);
            crc(19)           := crc(20) xor crc_feedback;
            crc(20)           := crc(21) xor crc_feedback;
            crc(21)           := crc(22) xor crc_feedback;
            crc(22)           := crc(23);
            crc(23)           := crc(24) xor crc_feedback;
            crc(24)           := crc(25) xor crc_feedback;
            crc(25)           := crc(26);
            crc(26)           := crc(27) xor crc_feedback;
            crc(27)           := crc(28) xor crc_feedback;
            crc(28)           := crc(29);
            crc(29)           := crc(30) xor crc_feedback;
            crc(30)           := crc(31) xor crc_feedback;
            crc(31)           :=             crc_feedback;
          end loop;
      
          -- return the CRC result
          return not crc;
        end calc_crc;
      
      
        ------------------------------------------------------------------------------
        -- Test Bench signals and constants
        ------------------------------------------------------------------------------
      
        -- Delay to provide setup and hold timing at the GMII/RGMII.
        constant dly : time := 5.8 ns;
        constant gtx_period : time := 2.5 ns;
              constant gm_clk : time := 4 ns;

        -- testbench signals
        signal gtx_clk              : std_logic;
        signal gtx_clkn             : std_logic;
        signal reset                : std_logic := '1';
        signal demo_mode_error      : std_logic := '0';
      
        signal mdc                  : std_logic;
        signal mdio                 : std_logic;
        signal mdio_count           : unsigned(5 downto 0);
        signal last_mdio            : std_logic;
        signal mdio_read            : std_logic;
        signal mdio_addr            : std_logic;
        signal mdio_fail            : std_logic;
                signal  phy_resetn : std_logic;
        signal  gmii_txd : std_logic_vector(7 downto 0);
        signal  gmii_tx_en : std_logic;
        signal  gmii_tx_er : std_logic;
        signal gmii_tx_clk : std_logic;
        
        
        signal  gmii_rxd : std_logic_vector(7 downto 0):=(others=>'0');
        
        signal  gmii_rx_dv : std_logic;
        signal  gmii_rx_er : std_logic:='0';
        signal  gmii_rx_clk : std_logic;
 signal    DUT_RESET_P     : std_logic;    
 signal    DUT_RESET_N     : std_logic; 
                   
 signal    RX_UT_p         : std_logic;  
 signal    RX_UT_n         : std_logic;   
 signal    TX_UT_p        : std_logic;   
 signal    TX_UT_n        : std_logic;   
     
 signal    TX_PRE_SEL_P        : std_logic;  
 signal    TX_PRE_SEL_N        : std_logic;  
 signal    TX_RF_PULSE_P      : std_logic;   
 signal    TX_RF_PULSE_N      : std_logic;   
                   
 signal    RX_DATA_WIN_P       : std_logic;  
 signal    RX_DATA_WIN_N       : std_logic;  
 signal    TX_BEAM_INI_P      : std_logic;   
 signal    TX_BEAM_INI_N      : std_logic;   
                   
 signal    TX_BEAM_HOP_P       : std_logic;  
 signal    TX_BEAM_HOP_N       : std_logic;  
 signal    TRC_CLK_REF_P      : std_logic;   
 signal    TRC_CLK_REF_N      : std_logic;   
                   
 signal    Monitor_enable    : std_logic; 
 signal     Monitor_TXD        : std_logic;  
begin
p_mdio_count : process (mdc, reset)
 begin
    if (reset = '1') then
       mdio_count <= (others => '0');
       last_mdio <= '0';
    elsif mdc'event and mdc = '1' then
       last_mdio <= mdio;
       if mdio_count >= "100000" then
          mdio_count <= (others => '0');
       elsif (mdio_count /= "000000") then
          mdio_count <= mdio_count + "000001";
       else  -- only get here if mdio state is 0 - now look for a start
          if mdio = '1' and last_mdio = '0' then
             mdio_count <= "000001";
          end if;
       end if;
    end if;
 end process p_mdio_count;

 mdio <= '1' when (mdio_read = '1' and (mdio_count >= "001110") and (mdio_count <= "011111")) else 'Z';

 -- only respond to phy and reg address == 1 (PHY_STATUS)
 p_mdio_check : process (mdc, reset)
 begin
    if (reset = '1') then
       mdio_read <= '0';
       mdio_addr <= '1'; -- this will go low if the address doesn't match required
       mdio_fail <= '0';
    elsif mdc'event and mdc = '1' then
       if (mdio_count = "000010") then
          mdio_addr <= '1';  -- reset at the start of a new access to enable the address to be revalidated
          if last_mdio = '1' and mdio = '0' then
             mdio_read <= '1';
          else -- take a write as a default as won't drive at the wrong time
             mdio_read <= '0';
          end if;
       elsif mdio_count <= "001100" then
          -- check the phy_addr is 7 and the reg_addr is 0
          if mdio_count <= "000111" and mdio_count >= "000101" then
             if (mdio /= '1') then
                mdio_addr <= '0';
             end if;
          else
             if (mdio /= '0') then
                mdio_addr <= '0';
             end if;
          end if;
       elsif mdio_count = "001110" then
          if mdio_read = '0' and (mdio = '1' or last_mdio = '0') then
             assert false
               report "ERROR -  Write TA phase is incorrect" & cr
               severity failure;
          end if;
       elsif (mdio_count >= "001111") and (mdio_count <= "011110") and mdio_addr = '1' then
          if (mdio_read = '0') then
             if (mdio_count = "010100") then
                if (mdio = '1') then
                   mdio_fail <= '1';
                   assert false
                     report "ERROR -  Expected bit 10 of mdio write data to be 0" & cr
                     severity failure;
                end if;
             else
                if (mdio = '0') then
                   mdio_fail <= '1';
                   assert false
                     report "ERROR -  Expected all except bit 10 of mdio write data to be 1" & cr
                     severity failure;
                end if;
             end if;
          end if;
       end if;
    end if;
 end process p_mdio_check;
--  lk : process
--    begin
--      gmii_rx_clk <= '0'; 
--      loop
--        wait for gm_clk;
--        gmii_rx_clk <= '1';
--      
--        wait for gm_clk;
--        gmii_rx_clk <= '0';
--       
--      end loop;
--    end process lk;
 
 p_gtx_clk : process
   begin
     clk_in_p <= '0';
     clk_in_n <= '1';
    
     loop
       wait for gtx_period;
       clk_in_p <= '1';
       clk_in_n <= '0';
       wait for gtx_period;
       clk_in_p <= '0';
       clk_in_n <= '1';
     end loop;
   end process p_gtx_clk;
   gmii_rx_clk <= gmii_tx_clk;
      p_stimulus : process
  
      ----------------------------------------------------------
      -- Procedure to inject a frame into the receiver at 1Gb/s
      ----------------------------------------------------------
      procedure send_frame_1g (current_frame : in natural) is
        variable current_col   : natural := 0;  -- Column counter within frame
        variable fcs           : std_logic_vector(31 downto 0);
      begin
  wait for 1000 ns;
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';
  
        -- Reset the FCS calculation
        fcs         := (others => '0');
  
        -- Adding the preamble field
        for j in 0 to 7 loop
          gmii_rxd   <= "01010101" after dly;
          gmii_rx_dv <= '1' after dly;
          gmii_rx_er <= '0' after dly;
          wait until gmii_rx_clk'event and gmii_rx_clk = '1';
        end loop;
  
        -- Adding the Start of Frame Delimiter (SFD)
        gmii_rxd   <= "11010101" after dly;
        gmii_rx_dv <= '1' after dly;
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';
        current_col := 0;
        gmii_rxd     <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
        gmii_rx_dv   <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
        gmii_rx_er   <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;
        fcs          := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
  
        wait until gmii_rx_clk'event and gmii_rx_clk = '1';
  
        current_col := current_col + 1;
        -- loop over columns in frame.
        while frame_data(current_frame).columns(current_col).valid /= '0' loop
          -- send one column of data
          gmii_rxd   <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
          gmii_rx_dv <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
          gmii_rx_er   <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;
          fcs          := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
  
          current_col := current_col + 1;
          wait until gmii_rx_clk'event and gmii_rx_clk = '1';
  
        end loop;
  
        -- Send the CRC.
        for j in 0 to 3 loop
           gmii_rxd   <= fcs(((8*j)+7) downto (8*j)) after dly;
           gmii_rx_dv <= '1' after dly;
           gmii_rx_er <= '0' after dly;
          wait until gmii_rx_clk'event and gmii_rx_clk = '1';
        end loop;
  
          -- Clear the data lines.
          gmii_rxd   <= (others => '0') after dly;
          gmii_rx_dv <=  '0' after dly;
  
          -- Adding the minimum Interframe gap for a receiver (8 idles)
          for j in 0 to 7 loop
            wait until gmii_rx_clk'event and gmii_rx_clk = '1';
				--wait for  ns;   -- updated
          end loop;
  
      end send_frame_1g;
  
  
    begin
  
  
      -- Send four frames through the MAC and Design Exampled
      -- at each state Ethernet speed
      --      -- frame 0 = minimum length frame
      --      -- frame 1 = type frame
      --      -- frame 2 = errored frame
      --      -- frame 3 = padded frame
      -------------------------------------------------------
  
  
      -- 1 Gb/s speed
      -------------------------------------------------------
      -- Wait for the Management MDIO transaction to finish.
     -- wait until management_config_finished;
      -- Wait for the internal resets to settle
      wait for 800 ns;
  
      assert false
        report "Sending four frames at 1Gb/s..." & cr
        severity note;
  
      for current_frame in frame_data'low to frame_data'high loop
		wait for 5 us;
        send_frame_1g(current_frame);
		  wait for 30 us;
      end loop;
 
      -- Wait for 1G monitor process to complete.
     -- wait until tx_monitor_finished_1G;
      wait for 10 ns;
  
      --rx_stimulus_finished <= true;
  
      -- Our work here is done
      if (demo_mode_error = '0' ) then
        assert false
          report "Test completed successfully"
          severity note;
      end if;
--      assert false
--        report "Simulation stopped"
--        severity failure;
    end process p_stimulus;
  
   p_timebomb : process
  begin
    if TB_MODE = "BIST" then
       wait for 600 us;
    else
       wait for 100 ms;
    end if;
    assert false
      report "ERROR - Simulation running forever!"
      severity failure;
  end process p_timebomb;
  
    ------------------------------------------------------------------------------
    -- Monitor process. This process checks the data coming out of the
    -- transmitter to make sure that it matches that inserted into the
    -- receiver.
    ------------------------------------------------------------------------------
    p_monitor : process
  
      ---------------------------------------------------
      -- Procedure to check a transmitted frame at 1Gb/s
      ---------------------------------------------------
      procedure check_frame_1g (current_frame : in natural) is
        variable current_col   : natural := 0;  -- Column counter within frame
        variable fcs           : std_logic_vector(31 downto 0);
        variable frame_type    : string(1 to 4) := (others => ' ');
      begin
  
        -- Reset the FCS calculation
        fcs         := (others => '0');
  
        -- Parse over the preamble field
        while gmii_tx_en /= '1' or gmii_txd = "01010101" loop
          wait until gmii_tx_clk'event and gmii_tx_clk = '1';
        end loop;
  
        -- Parse over the Start of Frame Delimiter (SFD)
        if (gmii_txd /= "11010101") then
          demo_mode_error <= '1';
          assert false
            report "SFD not present" & cr
            severity error;
        end if;
        wait until gmii_tx_clk'event and gmii_tx_clk = '1';
  
        if TB_MODE = "DEMO" then
  
           -- Start comparing transmitted data to received data
           assert false
             report "Comparing Transmitted Data Frames to Received Data Frames" & cr
             severity note;
  
           -- frame has started, loop over columns of frame
           while ((frame_data(current_frame).columns(current_col).valid)='1') loop
  
               if gmii_tx_en /= to_stdulogic(frame_data(current_frame).columns(current_col).valid) then
                 demo_mode_error <= '1';
                 assert false
                   report "gmii_tx_en incorrect" & cr
                   severity error;
               end if;
  
               if gmii_tx_en = '1' then
  
                 -- The transmitted Destination Address was the Source Address of the injected frame
                 if current_col < 6 then
                   if gmii_txd(7 downto 0) /=
                         to_stdlogicvector(frame_data(current_frame).columns(current_col+6).data(7 downto 0)) then
                     demo_mode_error <= '1';
                     assert false
                       report "gmii_txd incorrect during Destination Address field" & cr
                       severity error;
                   end if;
  
                 -- The transmitted Source Address was the Destination Address of the injected frame
                 elsif current_col >= 6 and current_col < 12 then
                   if gmii_txd(7 downto 0) /=
                         to_stdlogicvector(frame_data(current_frame).columns(current_col-6).data(7 downto 0)) then
                     demo_mode_error <= '1';
                     assert false
                       report "gmii_txd incorrect during Source Address field" & cr
                       severity error;
                   end if;
  
                 -- for remainder of frame
                 else
                   if gmii_txd(7 downto 0) /=
                         to_stdlogicvector(frame_data(current_frame).columns(current_col).data(7 downto 0)) then
                     demo_mode_error <= '1';
                     assert false
                       report "gmii_txd incorrect" & cr
                       severity error;
                   end if;
                 end if;
             end if;
  
             -- calculate expected crc for the frame
             fcs        := calc_crc(gmii_txd, fcs);
  
             -- wait for next column of data
             current_col        := current_col + 1;
             wait until gmii_tx_clk'event and gmii_tx_clk = '1';
           end loop;  -- while data valid
  
           -- Check the FCS matches that expected from calculation
           -- Having checked all data columns, txd must contain FCS.
           for j in 0 to 3 loop
             if gmii_tx_en = '0' then
               demo_mode_error <= '1';
               assert false
                 report "gmii_tx_en incorrect during FCS field" & cr
                 severity error;
             end if;
  
             if gmii_txd /= fcs(((8*j)+7) downto (8*j)) then
               demo_mode_error <= '1';
               assert false
                 report "gmii_txd incorrect during FCS field" & cr
                 severity error;
             end if;
  
             wait until gmii_tx_clk'event and gmii_tx_clk = '1';
           end loop;  -- j
  
        else
           frame_type     := (others => ' ');
           while (gmii_tx_en='1') loop
             if current_col = 12 and gmii_txd = X"81" then
                frame_type := "VLAN";
             end if;
             -- wait for next column of data
             current_col        := current_col + 1;
             wait until gmii_tx_clk'event and gmii_tx_clk = '1';
  
           end loop;  -- while data valid
           assert false
             report frame_type & " Frame tramsmitted : Size " & integer'image(current_col) & cr
             severity note;
        end if;
      end check_frame_1g;
  
  
      variable f                  : mac_ip_frame_typ;       -- temporary frame variable
      variable current_frame      : natural   := 0;  -- current frame pointer
  
  
    begin  -- process p_monitor
  
  
      -- Compare the transmitted frame to the received frames
      --      -- frame 0 = minimum length frame
      --      -- frame 1 = type frame
      --      -- frame 2 = errored frame
      --      -- frame 3 = padded frame
      -- Repeated for all stated speeds.
      -------------------------------------------------------
  
      -- wait for reset to complete before starting monitor to ignore false startup errors
      wait until reset'event and reset = '0';
  
      if TB_MODE = "DEMO" then
  
         -- 1 Gb/s speed
         -------------------------------------------------------
  
         current_frame      := 0;
  
  
         -- Look for 1Gb/s frames.
         -- loop over all the frames in the stimulus record
         loop
  
           -- If the current frame had an error inserted then it would have been
           -- dropped by the FIFO in the design example.  Therefore move immediately
           -- on to the next frame.
           while frame_data(current_frame).bad_frame loop
             current_frame := current_frame + 1;
           if current_frame = frame_data'high + 1 then
               exit;
             end if;
           end loop;
  
           -- There are only 4 frames in this test.
           if current_frame = frame_data'high + 1 then
             exit;
           end if;
  
           -- Check the current frame
           check_frame_1g(current_frame);
  
           -- move to the next frame
           if current_frame = frame_data'high then
             exit;
           else
             current_frame := current_frame + 1;
           end if;
  
         end loop;
  
         wait for 200 ns;
         --tx_monitor_finished_1G <= true;
  
  
         wait;
      else
         loop
           check_frame_1g(current_frame);
         end loop;
      end if;
    end process p_monitor;
reset <= '0' after 400 ns;
u0: TOP port map(

    clk_in_p		  =>   clk_in_p,
		clk_in_n		  =>   clk_in_n,
	--	rst           =>  reset,
      phy_resetn    =>     phy_resetn,    			
            mdio    =>       mdio,                
            mdc     =>        mdc,               
      gmii_txd      =>        gmii_txd,        
      gmii_tx_en    =>        gmii_tx_en,        
      gmii_tx_er    =>         gmii_tx_er,       
      gmii_tx_clk   =>          gmii_tx_clk,      
      gmii_rxd      =>          gmii_rxd,      
      gmii_rx_dv    =>         gmii_rx_dv,       
      gmii_rx_er    =>         gmii_rx_er,       
      gmii_rx_clk   =>          gmii_rx_clk,      
      
		DUT_RESET_P    =>   DUT_RESET_P ,
	--	DUT_RESET_N    =>   DUT_RESET_N ,
		                    
		RX_UT_p        =>   TX_UT_p     ,
	--	RX_UT_n        =>   RX_UT_n     ,
		TX_UT_p       	=>   TX_UT_p     ,
	--	TX_UT_n       	=>   TX_UT_n     ,
		
		TX_PRE_SEL_P   =>   TX_PRE_SEL_P  ,
	--	TX_PRE_SEL_N   =>   TX_PRE_SEL_N  ,
		TX_RF_PULSE_P  =>   TX_RF_PULSE_P ,
	--	TX_RF_PULSE_N  =>   TX_RF_PULSE_N ,
		                    
		RX_DATA_WIN_P  =>   RX_DATA_WIN_P ,
	--	RX_DATA_WIN_N  =>   RX_DATA_WIN_N ,
		TX_BEAM_INI_P  =>   TX_BEAM_INI_P ,
	--	TX_BEAM_INI_N  =>   TX_BEAM_INI_N ,
		                    
		TX_BEAM_HOP_P  =>   TX_BEAM_HOP_P ,
	--	TX_BEAM_HOP_N  =>   TX_BEAM_HOP_N ,
		TRC_CLK_REF_P  =>   TRC_CLK_REF_P ,
	--	TRC_CLK_REF_N  =>   TRC_CLK_REF_N ,
	                       
      Monitor_enable =>   Monitor_enable ,     
       Monitor_TXD   =>    Monitor_TXD ,

self_preselect       =>         TX_PRE_SEL_P     ,
self_tx_pulse        =>         self_tx_pulse      ,
self_data_window     =>         self_data_window   ,
self_beam_ini        =>         self_beam_ini      ,
self_beam_hop        =>         self_beam_hop      ,
self_test_reset        =>       self_test_reset  ,  
self_clk_ref3MHz       =>       self_clk_ref3MHz  , 
self_monitor_txd       =>       self_monitor_txd   ,
self_monitor_enable    =>       self_monitor_enable,
self_trm_PSU_ON       =>        self_trm_PSU_ON    ,
self_trm_PSU_OFF      =>        self_trm_PSU_OFF   ,
Self_PDU_SYNC         =>        Self_PDU_SYNC      ,
self_test_RX_UT		 =>			self_test_RX_UT,
self_test_Tx_ut		 =>			self_test_Tx_ut,

direction4_1       =>     open,
direction5_0       =>    open,
direction6_1       =>    open,
direction7_1       =>    open,
direction8_1       =>    open,

direction12_0     =>    open,
direction13_1     =>    open,
direction14_0     =>    open,
direction15_0     =>    open,
direction16_0     =>    open


	
		
);




end Behavioral;
