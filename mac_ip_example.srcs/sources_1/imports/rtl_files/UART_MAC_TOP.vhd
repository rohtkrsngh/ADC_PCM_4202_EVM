----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2016 04:11:03 PM
-- Design Name: 
-- Module Name: UART_MAC_TOP - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity UART_MAC_TOP is
generic (
         BAUD_RATE   : integer := 5000000;           -- serves as clock divisor
         CLOCK_RATE  : integer := 125000000        -- freq of clk
      );
      Port ( rst_clk_rx    : in  STD_LOGIC;              -- active high, managed synchronously
                clk_rx        : in  STD_LOGIC;              -- operational clock
                rx_IN        : in  STD_LOGIC;
               rx_sclk        : in  STD_LOGIC;
             
				  start_bit_num    : in  std_logic_vector(3 downto 0); 
				 word_length     :  in  std_logic_vector(7 downto 0);
			--	 frame_length    :  in  std_logic_vector(7 downto 0);
				  clk_200        :  in std_logic;               -- directly from pad - not yet associated with any time domain
                rx_data       : out STD_LOGIC_VECTOR (15 downto 0);   -- 8 bit data output valid when rx_data_rdy is asserted
                rx_data_rdy   : out STD_LOGIC;     
                valid_dut     : in std_logic;         -- active high signal indicating rx_data is valid
                frm_err       : out STD_LOGIC               -- framing error - active high when STOP bit not detected
               );
end UART_MAC_TOP;

architecture Behavioral of UART_MAC_TOP is


signal baud_x16_en      : std_logic := 'U';
signal rxd_clk_rx       : std_logic := 'U';
SIGNAL RXD_I_S : STD_LOGIC;


COMPONENT uart_rx_ctl is
    Port ( clk_rx           : in  STD_LOGIC;
	        rd_clk           : in std_logic;
           rst_clk_rx       : in  STD_LOGIC;
           baud_x16_en      : in  STD_LOGIC;
           rxd_clk_rx       : in  STD_LOGIC;
           rx_data          : out STD_LOGIC_VECTOR (15 downto 0);
			  start_bit_num    : in  std_logic_vector(3 downto 0); 
			  word_length     :  in  std_logic_vector(7 downto 0);
		
			  rx_data_rdy      : out STD_LOGIC;
           valid_dut        : in std_logic;
           frm_err          : out STD_LOGIC
          );
end COMPONENT uart_rx_ctl;

COMPONENT uart_baud_gen is
     Generic (CLOCK_RATE    : integer := 125_000_000;                    -- clock rate
              BAUD_RATE     : integer :=   10_000_000                     -- desired baud rate
             );                      
    Port ( rst              : in  STD_LOGIC;                             -- external reset in
           clk              : in  STD_LOGIC;                             -- clock 
           baud_x16_en      : out STD_LOGIC                              -- 16 times the baud rate
           );
end COMPONENT uart_baud_gen;
begin

uart_baud_gen_rx_i0: uart_baud_gen 
           generic map (CLOCK_RATE  => CLOCK_RATE,
                        BAUD_RATE   => BAUD_RATE)                      
           port map    (rst         => rst_clk_rx,
                        clk         => clk_200, 
                        baud_x16_en => baud_x16_en
                 );
       
       --
       -- receiver state machine
       uart_rx_ctl_i0: uart_rx_ctl PORT MAP(
          clk_rx      => rx_sclk, --clk_200 ,
			 rd_clk      => clk_rx,
          rst_clk_rx  => rst_clk_rx,
          baud_x16_en => baud_x16_en,
          rxd_clk_rx  => rx_in,
          rx_data     => rx_data,
			  start_bit_num    => X"1",
			  word_length      =>  X"08",--word_length,
	
          rx_data_rdy => rx_data_rdy,
          valid_dut   => valid_dut,
          frm_err     => frm_err 
       );
       
--              IBUFDS_inst : IBUFDS
--          generic map (
--             DIFF_TERM => TRUE, -- Differential Termination (on June 5 14)
--             IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--             IOSTANDARD => "DEFAULT")
--          port map (
--             O    => rxd_i_s,                -- Buffer output
--             I    => RX_IN_p,          -- Diff_p buffer input (connect directly to top-level port)
--             IB   => RX_IN_n           -- Diff_n buffer input (connect directly to top-level port)
--          );
--          
         
       
           
end Behavioral;
