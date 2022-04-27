----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2014 12:36:36 PM
-- Design Name: 
-- Module Name: WR_BUFFER_BANK - Behavioral
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

entity WR_BUFFER_BANK is

    Port (DIN_WBB               : in    std_logic_vector(31 downto 0);
          CLK1_WBB              : in    std_logic;
          DIN_RDY_WBB           : in    std_logic_vector(3 downto 0);
          DOUT_WBB              : out   std_logic_vector(31 downto 0);
          CLK2_WBB              : in    std_logic; 
          RST_WBB               : in    std_logic;
          FIFO_RD_EN_WBB        : in    std_logic_vector(3 downto 0); 
			 frame_length          : in    std_logic_vector(7 downto 0);
          Rd_Cnt_Bf_Wbb         : out   std_logic_vector(39 downto 0);
          Full_Fifo             : out   std_logic_vector(3 downto 0);
          Empty_Fifo            : out   std_logic_vector(3 downto 0);
          Prog_Full             : out   std_logic_vector(3 downto 0);
          Prog_Empty            : out   std_logic_vector(3 downto 0);
          Rd_LL_Wbb             : in    std_logic_vector(3 downto 0); 
          Dout_LL_Wbb           : out   std_logic_vector(31 downto 0);
          Full_LL_Wbb           : out   std_logic_vector(3 downto 0); 
          Empty_LL_Wbb          : out   std_logic_vector(3 downto 0); 
          Data_Cnt_LL_Wbb       : out   std_logic_vector(15 downto 0); 
          rx_pkt_cmplt          : out   std_logic_vector(3 downto 0)
 
          
          );
end WR_BUFFER_BANK;

architecture WR_BUFFER_BANK_a of WR_BUFFER_BANK is

signal   DIN_WBB_s             :      std_logic_vector(31 downto 0);
signal   CLK1_WBB_s            :      std_logic;
signal   DIN_RDY_WBB_s         :      std_logic_vector(3 downto 0); 
signal   DOUT_WBB_s            :      std_logic_vector(31 downto 0);
signal   CLK2_WBB_s            :      std_logic;                    
signal   RST_WBB_s             :      std_logic;                     
signal   Full_Fifo_s           :      std_logic_vector(3 downto 0);
signal   Empty_Fifo_s          :      std_logic_vector(3 downto 0);
signal   Rd_Data_Count_Wrb_s   :      std_logic_vector(39 downto 0);
signal   Prog_Full_s           :      std_logic_vector(3 downto 0);
signal   Prog_Empty_s          :      std_logic_vector(3 downto 0);
signal   Fifo_Rd_En_s          :      std_logic_vector(3 downto 0);
signal   Rd_LL_Wbb_s           :      std_logic_vector(3 downto 0);                  
signal   Dout_LL_Wbb_s         :      std_logic_vector(31 downto 0);
signal   Full_LL_Wbb_s         :      std_logic_vector(3 downto 0);                    
signal   Empty_LL_Wbb_s        :      std_logic_vector(3 downto 0);                   
signal   Data_Cnt_LL_Wbb_s     :      std_logic_vector(15 downto 0); 
signal  valid_out_s :    std_logic_vector(3 downto 0); 
attribute keep: boolean;
attribute keep of valid_out_s : signal is true;

component WR_BUFFER is
    Port (DIN_WRB               : in    std_logic_vector(7 downto 0);
          CLK1_WRB              : in    std_logic;
          DIN_RDY_WRB           : in    std_logic;
          DOUT_WRB              : out   std_logic_vector(7 downto 0);
          CLK2_WRB              : in    std_logic;
          RST_WRB               : in    std_logic;
          Full_Fifo             : out   std_logic;
          Empty_Fifo            : out   std_logic;
          Rd_Data_Count_Wrb     : out   std_logic_vector(9 downto 0);
--          Wr_Data_Count         : out   std_logic;
          frame_length          : in    std_logic_vector(7 downto 0);
          Prog_Full             : out   std_logic;
          Prog_Empty            : out   std_logic;
          Fifo_Rd_En            : in    std_logic;
          Rd_LL_Wrb             : in    std_logic;                   
          Dout_Fifo_LL          : out   std_logic_vector(7 downto 0);
          Full_LL               : out   std_logic;                   
          Empty_LL              : out   std_logic;                   
          Data_Count_LL         : out   std_logic_vector(3 downto 0);
           valid_out_s :    out   std_logic;
			 rx_pkt_cmplt          : out   std_logic		

          
          );

end component WR_BUFFER;

begin

DIN_WBB_s       <=    DIN_WBB;    
CLK1_WBB_s      <=    CLK1_WBB;   
DIN_RDY_WBB_s   <=    DIN_RDY_WBB;
DOUT_WBB        <=    DOUT_WBB_s;   
CLK2_WBB_s      <=    CLK2_WBB;   
RST_WBB_s       <=    RST_WBB;    
Fifo_Rd_En_s    <=    FIFO_RD_EN_WBB;

Rd_LL_Wbb_s        <=     Rd_LL_Wbb;          
Dout_LL_Wbb        <=     Dout_LL_Wbb_s;    
Full_LL_Wbb        <=     Full_LL_Wbb_s;    
Empty_LL_Wbb       <=     Empty_LL_Wbb_s;   
Data_Cnt_LL_Wbb    <=     Data_Cnt_LL_Wbb_s;
Rd_Cnt_Bf_Wbb      <=     Rd_Data_Count_Wrb_s;
rx_pkt_cmplt(3)       <=     '0'; 

U_WR_BB :
for i in 0 to 2 generate
begin
U0 : WR_BUFFER
port map (
            DIN_WRB               => DIN_WBB_s(8*i+7 downto 8*i),
            CLK1_WRB              => CLK1_WBB_s,
            DIN_RDY_WRB           => DIN_RDY_WBB_s(i),
            DOUT_WRB              => DOUT_WBB_s(8*i+7 downto 8*i),
            CLK2_WRB              => CLK2_WBB_s,
            RST_WRB               => RST_WBB_s,
            Full_Fifo             => Full_Fifo_s(i),
            Empty_Fifo            => Empty_Fifo_s(i),
            Rd_Data_Count_Wrb     => Rd_Data_Count_Wrb_s(10*i+9 downto 10*i),
            frame_length          => frame_length,
            Prog_Full             => Prog_Full_s(i),
            Prog_Empty            => Prog_Empty_s(i),
            Fifo_Rd_En            => Fifo_Rd_En_s(i),
            Rd_LL_Wrb             => Rd_LL_Wbb_s(i),       
            Dout_Fifo_LL          => Dout_LL_Wbb_s(8*i+7 downto 8*i),     
            Full_LL               => Full_LL_Wbb_s(i),     
            Empty_LL              => Empty_LL_Wbb_s(i), 
             valid_out_s => valid_out_s(i),   
            Data_Count_LL         => Data_Cnt_LL_Wbb_s(4*i+3 downto 4*i), 
            rx_pkt_cmplt          => rx_pkt_cmplt(i)
            );

end generate U_WR_BB;



end architecture WR_BUFFER_BANK_a;
