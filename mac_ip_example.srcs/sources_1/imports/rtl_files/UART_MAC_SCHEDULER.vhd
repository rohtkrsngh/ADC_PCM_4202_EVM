----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:15:54 04/16/2019 
-- Design Name: 
-- Module Name:    rx_info_schd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_info_schd is
port (    DIN_WRB           : in    std_logic_vector(7 downto 0);
          CLK1_WRB          : in    std_logic;
          DIN_RDY_WRB       : in    std_logic;
			 RST_WRB           : in    std_logic;
			 Rd_Req            : in    std_logic;
			 ch_sel_id         : in    std_logic_vector(7 downto 0);
          DOUT_WRB          : out   std_logic_vector(7 downto 0);
			  DOUT_RDY_wrb     : out   STD_LOGIC;                       
           LEN_PLD_wrb      : out   STD_LOGIC_VECTOR (7 downto 0)
	   );
end rx_info_schd;

architecture Behavioral of rx_info_schd is

component FIFO_WBB is
  PORT (
    rst             : IN    STD_LOGIC;
    wr_clk          : IN    STD_LOGIC;
    rd_clk          : IN    STD_LOGIC;
    din             : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en           : IN    STD_LOGIC;
    rd_en           : IN    STD_LOGIC;
    dout            : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    full            : OUT   STD_LOGIC;
    empty           : OUT   STD_LOGIC;
	 valid           : OUT   STD_LOGIC;
    rd_data_count   : OUT   STD_LOGIC_VECTOR(9 DOWNTO 0);
    wr_data_count   : OUT   STD_LOGIC_VECTOR(9 DOWNTO 0)
    
  );
end component FIFO_WBB;


type Wr_Buff_st is (S0_Wr_Bf,s1, s2,s3, s4, s5, s6);
signal Wr_Bf_Ns                : Wr_Buff_st;        -- Next State Signal.
signal Wr_Bf_Cs                : Wr_Buff_st;        -- Current State Signal.
signal wait_count_en  : std_logic;
signal wait_count  : std_logic_vector(19 downto 0) := (others => '0');
signal  rd_rx_len   : std_logic;
signal rd_en_count  : std_logic;
signal rd_fifo_count : std_logic_vector(7 downto 0) := (others => '0');
signal  rx_pkt_len: std_logic_vector(7 downto 0) := (others => '0');
signal  Fifo_Rd_En_s : std_logic;
signal Rd_Data_Count_s: std_logic_vector(9 downto 0) := (others => '0');
signal wr_Data_Count_s: std_logic_vector(9 downto 0) := (others => '0');
signal DOUT_RDB_s: std_logic_vector(7 downto 0) := (others => '0');
signal ch_no_data, ch_no_data_q, valid_out, ch_no_data_q2 : std_logic;

begin


proc3_WRB : process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
    if (RST_WRB = '1') then   
      Wr_Bf_Cs  <= S0_Wr_Bf;
    else
      Wr_Bf_Cs  <= Wr_Bf_Ns ;    
    end if;
  end if;
end process proc3_WRB;
process(CLK1_WRB)      
begin                                
  if rising_edge(CLK1_WRB) then
  if wait_count_en = '1' then
   wait_count <= wait_count + '1';
	else
	wait_count <= (others => '0');
	end if;
	end if;
end process;
 
----------Next State Computation ----------------------------------------------

proc4_WRB : process(Wr_Bf_Cs,wait_count, DIN_RDY_WRB, Rd_Req, rd_fifo_count)
begin 
  case Wr_Bf_Cs is
    when S0_Wr_Bf =>
      if (RST_WRB = '1') then
        Wr_Bf_Ns  <= S0_Wr_Bf;
      elsif (DIN_RDY_WRB = '1' ) then
        Wr_Bf_Ns      <= s1;
      else
        Wr_Bf_Ns  <= S0_Wr_Bf;
      end if;
   	wait_count_en    <=  '0'; 
      rd_rx_len        <= '0';
		rd_en_count      <=  '0';
      ch_no_data       <=   '0';
 when s1 =>
     wait_count_en    <=  '0'; 
	  rd_rx_len        <= '0';
		rd_en_count      <=  '0';
      ch_no_data       <=   '0';
	   Wr_Bf_Ns        <=   s2; 
  
  when s2 => 
 
	   wait_count_en    <=  '1'; 
		rd_en_count      <=  '0';
      ch_no_data       <=   '0';
		if wait_count  < X"7A120" then  --7A120
		   if DIN_RDY_WRB = '1' then
         Wr_Bf_Ns         <= s1;
		   else
		   Wr_Bf_Ns         <=s2;
		   end if;
		else
		Wr_Bf_Ns         <= s3;
	   end if;

    when s3 =>
	 	wait_count_en    <=  '0';
      rd_rx_len        <= '1';
		rd_en_count      <=  '0';
      ch_no_data       <=   '0';
      Wr_Bf_Ns         <= s4;
 
    when s4 =>
	 	wait_count_en    <= '0';
      rd_rx_len        <= '0';
		rd_en_count      <=  '0';
         if Rd_Req='1' then
		 Wr_Bf_Ns         <= s5;
      ch_no_data       <=   '1';
		   else
		   Wr_Bf_Ns         <=s4;
      ch_no_data       <=   '0';
		   end if;	
                 
    when s5 =>
		wait_count_en    <= '0';
      rd_rx_len        <= '0'; 
		rd_en_count      <=  '0';
      ch_no_data       <=   '0';
      if rd_fifo_count <= rx_pkt_len then
		Wr_Bf_Ns      <= s5;
		rd_en_count      <=  '1';
		 else
      Wr_Bf_Ns      <= s6;
		rd_en_count      <=  '0';
		  end if;
   
 when s6 =>
      
      ch_no_data       <=   '0';
	 	wait_count_en    <=  '0';
	 rd_rx_len     <= '0';
      Wr_Bf_Ns         <= S0_Wr_Bf;
     		rd_en_count      <=  '0';
when others => 
   null;
  end case;
  
end process proc4_WRB;

------------- Write Counter -------------------------

proc5_Wr_Cnt : process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
    if (wait_count_en = '1') then 
      wait_count  <= wait_count + '1';
    else    
      wait_count  <= (others => '0');      
    end if;
  end if;
end process proc5_Wr_Cnt;



 process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
  if (RST_WRB = '1') then
  rx_pkt_len <= X"00";
   elsif rd_rx_len = '1' then
	  rx_pkt_len <= Wr_Data_Count_s(7 downto 0);
	 end if;
  end if;
  end process;
LEN_PLD_wrb <= rx_pkt_len;
 process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
    if (rd_en_count = '1') then 
      rd_fifo_count  <= rd_fifo_count + '1';
    else    
      rd_fifo_count  <= (others => '0');      
    end if;
  end if;
end process;

 process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
    if (rd_en_count = '1') then
     Fifo_Rd_En_s<= '1';
	  else
	  Fifo_Rd_En_s <= '0';
	 end if;
	end if;
end process;	

 process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
  ch_no_data_q <= ch_no_data;
   ch_no_data_q2 <= ch_no_data_q;
 
   if ch_no_data_q2 = '1' then
	 DOUT_WRB <= ch_sel_id;
	 elsif valid_out ='1' then
	 DOUT_WRB <= DOUT_RDB_s;
	 else
	 DOUT_WRB <= X"00";
	 end if;
end if;
end process;	 

 process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
   if Wr_Bf_Cs = s4 then
	 DOUT_RDY_wrb <= '1';
	 else
	 DOUT_RDY_wrb <= '0';
	 end if;
	end if;
end process;	

U0_WRB: FIFO_WBB
  PORT MAP (
    rst             => RST_WRB,
    wr_clk          => CLK1_WRB,
    rd_clk          => CLK1_WRB,
    din             => DIN_WRB,
    wr_en           => DIN_RDY_WRB,
    rd_en           => Fifo_Rd_En_s,
    dout            => DOUT_RDB_s,
	 valid           => valid_out,
    full            => open,
    empty           => open,
    rd_data_count   => Rd_Data_Count_s,
    wr_data_count   => Wr_Data_Count_s
   
  );

end Behavioral;
