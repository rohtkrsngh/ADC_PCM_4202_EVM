library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;
entity spi_ex is
generic(
  N                     : integer := 8;      -- number of bit to serialize
  CLK_DIV               : integer := 1 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)
 port (
  i_clk                     : in  std_logic;
  i_rstb                    : in  std_logic;
  i_tx_start                : in  std_logic;  -- start TX on serial line
  rd_en_fifo                : out std_logic;
  o_tx_end                  : out std_logic;  -- TX data completed; o_data_parallel available
  i_data_parallel           : in  std_logic_vector(N-1 downto 0);  -- data to sent
  o_data_parallel           : out std_logic_vector(15 downto 0);  -- received data
  
  o_data_fb                 : out std_logic_vector(15 downto 0);  -- received data
  len_frame_byt             : in  std_logic_vector(7 downto 0);
  word_length_bits          : in  STD_LOGIC_vector(7 downto 0);
  valid_data                : out std_logic;
  o_sclk                    : out std_logic;
  sob_enable                : out std_logic;
  o_ss                      : out std_logic;
  o_mosi                    : out std_logic;
  i_miso                    : in  std_logic;
  mosi_fb                   : in  std_logic
);
end spi_ex;
architecture rtl of spi_ex is
type t_spi_controller_fsm is (
                          ST_RESET   ,
                          ST_TX_RX   ,
                          ST_END     );
								  
signal o_tx_end1            : std_logic:='0';
signal o_tx_end2            : std_logic:='0';
signal 	so_mosi,so_mosi1,to_mosi : std_logic:='1';
signal 	so_sclk : std_logic:='1';						  
signal 	o_sclk1 : std_logic;						  

signal r_counter_clock        : integer range 0 to CLK_DIV*2;
signal r_sclk_rise            : std_logic;
signal r_sclk_fall            : std_logic;
signal r_counter_clock_ena    : std_logic;
signal r_counter_data         : integer range 0 to 17;
signal wr_cnt                 :integer range 0 to 17;-- std_logic_vector(3 downto 0):="0000";  -- data to sent
signal rd_cnt                 : integer range 0 to 20;--std_logic_vector(3 downto 0):="0000";  -- data to sent

signal w_tc_counter_data   : std_logic;
signal r_st_present        : t_spi_controller_fsm;
signal w_st_next           : t_spi_controller_fsm;
signal r_tx_start          : std_logic;  -- start TX on serial line
signal r_tx_data           : std_logic_vector(N-1 downto 0);  -- data to sent
signal r_rx_data           : std_logic_vector(17 downto 0);  -- received data
signal r_rx_data_fb        : std_logic_vector(17 downto 0);  -- received data

signal end_rx              :     std_logic_vector(7 downto 0):=X"00";  -- data to sent
signal valid_rx            :     std_logic:='0';
SIgnal en_fall_count       :     STD_LOGIC;
SIGNAL fall_count          :     STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
SIGNAL word_length         :     integer range 0 to 17;
begin

w_tc_counter_data  <= '0' when(r_counter_data > 0) else '1';
 
--------------------------------------------------------------------
process(i_clk)                      --  updated 10_oct 
begin
if rising_edge(i_clk) then
  if (i_tx_start ='1' ) then
  r_tx_start <=  '1';
  elsif o_tx_end2='1' then
  r_tx_start <='1';
  else
  r_tx_start<='0';
  end if;
end if;
end process;

process(i_clk)                      --  updated 10_oct 
begin
if rising_edge(i_clk) then
 if word_length_bits = X"08" then
   word_length    <=  9;
 elsif word_length_bits = X"16" then
   word_length    <=  17;	
end if;
end if;
end process;

process(i_clk)                      --   
begin
if rising_edge(i_clk) then
  if fall_count = X"01" then
    rd_en_fifo  <=  '1';
  elsif 	fall_count = X"10" and word_length > 9 then
    rd_en_fifo  <=  '1';
  else
    rd_en_fifo  <=  '0';
  end if;
end if;
end process;  




process(i_clk)                   --------updatedd
begin
if rising_edge(i_clk) then
if end_rx = len_frame_byt then     --   updated 10oct (38 to 19)
o_tx_end<=o_tx_end1;

else
o_tx_end<='0';
end if;
end if;
end process;



process(i_clk)                       --  not update 10OCT
begin
if rising_edge(i_clk) then
if end_rx < len_frame_byt then
o_tx_end2 <= o_tx_end1;
else
o_tx_end2 <= o_tx_end2;
end if;
end if;
end process;


process(i_clk)
begin
if rising_edge(i_clk) then

o_sclk1<=so_sclk;
else
o_sclk1<=o_sclk1;
end if;

end process;
o_sclk <= o_sclk1;
o_mosi <= to_mosi;

process(i_clk)
begin
if rising_edge(i_clk) then
if end_rx < len_frame_byt then
to_mosi   <= so_mosi;
else
to_mosi   <=  '1';
end if;
end if;
end process;

process(i_clk)
begin
if rising_edge(i_clk) then
so_mosi1<=so_mosi;
end if;
end process;




p_state : process(i_clk,i_rstb)  --,i_rstb  updated 17 july
begin
  if(i_rstb='1') then
    r_st_present            <= ST_RESET;
  elsif(rising_edge(i_clk)) then
    r_st_present            <= w_st_next;
  end if;
end process p_state;
p_comb : process(
                 r_st_present         ,
                 w_tc_counter_data    ,
                 r_tx_start           ,
                 r_sclk_rise          ,
                 r_sclk_fall          ,
                 r_counter_data, word_length,fall_count )
begin
  case r_st_present is
    when  ST_TX_RX      => 
      if (w_tc_counter_data='1') and (r_sclk_rise='1') then
		w_st_next  <= ST_END    ;
      else                                                         
		w_st_next      <=   ST_TX_RX  ;
      end if;
    
	 
	 if word_length = 9 then
	   
		if fall_count = X"12" then
		 en_fall_count   <=  '0';
		elsif r_counter_data < 2 then
		 en_fall_count   <=  '0';
		else
		 en_fall_count   <=  '1';
      end if;
	 else
	  en_fall_count   <=  '1';
	end if;	 
--	 if (r_counter_data <= 2 and word_length = 9 and fall_count > "11" ) then
--      -- if (fall_count = "11" and word_length = 9) then
--	    en_fall_count   <=  '0';
--		 else
--     	 en_fall_count   <=  '1';
--     --  end if;		
--	-- else
--   --  	 en_fall_count   <=  '1';
--	 end if;
	 
	 
	 when  ST_END      => 
	   en_fall_count     <=  '0';
      if(r_sclk_fall='1') then
        w_st_next  <= ST_RESET  ;  
      else
        w_st_next  <= ST_END    ;  
      end if;
   
	when  others            =>              -- ST_RESET
      if(r_tx_start='1') then   
		w_st_next      <= ST_TX_RX ;
		en_fall_count  <=  '1';
      else 
		en_fall_count  <=  '0';
		w_st_next      <= ST_RESET ;
      end if;
  end case;
end process p_comb;


p_state_clk_out : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    r_counter_data        <= word_length;       ---updated
    r_counter_clock_ena   <= '0';
    so_sclk               <= '1';
    o_ss                  <= '1';
  elsif(rising_edge(i_clk)) then
    case r_st_present is
      when ST_TX_RX         =>
        r_counter_clock_ena  <= '1';
        if(r_sclk_rise='1') then
          so_sclk            <= '1';
          if(r_counter_data>0) then
          r_counter_data       <= r_counter_data - 1;
          end if;
      
		  elsif(r_sclk_fall='1') then
        so_sclk               <= '0';
        end if;
        o_ss                 <= '0';
     
	  when ST_END          =>
        r_counter_data       <= word_length;                --updated
        r_counter_clock_ena  <= '1';
        o_ss                 <= '0';
		  so_sclk              <= '1';
      
      when others               =>  -- ST_RESET
        r_counter_data       <= word_length;                      --updated
        r_counter_clock_ena  <= '0';
        so_sclk              <= '1';
        o_ss                 <= '1';
    end case;
  end if;
end process p_state_clk_out;


r_tx_data            <=  i_data_parallel;

p_state_tx_out : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    so_mosi              <= '1';
    o_tx_end1            <= '0';

    
  elsif(rising_edge(i_clk)) then
    case r_st_present is
      when ST_TX_RX   =>
        o_tx_end1         <= '0';
		     CASE fall_count is
				  WHEN  X"00" =>  so_mosi   <=  '1';
			     WHEN  X"03" =>  so_mosi   <=  r_tx_data(0);
				  WHEN  X"05" =>  so_mosi   <=  r_tx_data(1);
				  WHEN  X"07" =>  so_mosi   <=  r_tx_data(2);
				  WHEN  X"09" =>  so_mosi   <=  r_tx_data(3);
				  WHEN  X"0B" =>  so_mosi   <=  r_tx_data(4);
				  WHEN  X"0D" =>  so_mosi   <=  r_tx_data(5);
				  WHEN  X"0F" =>  so_mosi   <=  r_tx_data(6);
				  WHEN  X"11" =>  so_mosi   <=  r_tx_data(7);
				  WHEN  X"13" =>  so_mosi   <=  r_tx_data(0);
				  WHEN  X"15" =>  so_mosi   <=  r_tx_data(1);
				  WHEN  X"17" =>  so_mosi   <=  r_tx_data(2);
				  WHEN  X"19" =>  so_mosi   <=  r_tx_data(3);
				  WHEN  X"1B" =>  so_mosi   <=  r_tx_data(4);
				  WHEN  X"1D" =>  so_mosi   <=  r_tx_data(5);
				  WHEN  X"1F" =>  so_mosi   <=  r_tx_data(6);
				  WHEN  X"21" =>  so_mosi   <=  r_tx_data(7);
				  WHEN  X"23" =>  so_mosi   <=  '1';
				  WHEN OTHERS =>  so_mosi   <=  so_mosi;
				               
				END CASE;   
		    
      when ST_END  =>
		   so_mosi        <=   '1';
         o_tx_end1      <=   r_sclk_fall;
		   end_rx         <=   end_rx + 1;
		   wr_cnt         <=   0;
      when others               =>  -- ST_RESET
        
        o_tx_end1             <= '0';
        so_mosi               <= '1';
		  if end_rx  =  len_frame_byt then
		  end_rx  <=  X"00";
		  end if;
    end case;
  end if;
end process p_state_tx_out;

PROCESS(i_clk)
BEGIN
 IF rising_edge(i_clk) THEN
    IF en_fall_count  =  '1'  THEN
	    fall_count  <=  fall_count + 1;
	 ELSE
       fall_count  <=  (OTHERS => '0');
    END IF;
 END IF;
 END PROCESS;
 

p_state_rx_in : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    o_data_parallel      <= (others=>'0');
    r_rx_data            <= (others=>'0');
	 r_rx_data_fb         <= (others=>'0');

    valid_data           <= '0';
	 
  elsif(rising_edge(i_clk)) then
    case r_st_present is
      when ST_TX_RX         =>
        if(r_sclk_fall = '1' and rd_cnt <= 17 ) then  ---(rd_cnt<=10 and rd_cnt>1 )  updated 24_7 : 8:50 PM
			 r_rx_data        <=  i_miso & r_rx_data(17 downto 1); --r_rx_data(16 downto 0) & i_miso; 
		    r_rx_data_fb     <=  r_rx_data_fb(16 downto 0) & mosi_fb; --mosi_fb & r_rx_data_fb(16 downto 1); --
			 rd_cnt           <=   rd_cnt + 1;                                   ---------updated 24_7 : 8:50 PM
		   end if;
			if rd_cnt = 18 then
         rd_cnt  <=  0;
		   end if;
		      valid_data <= '0';

      when ST_END          =>
        o_data_parallel    <=    r_rx_data(16 downto 1);
--		  o_data_parallel(0)      <=  r_rx_data(7);   --     r_rx_data(8);
--		  o_data_parallel(1)      <=  r_rx_data(6);    --    r_rx_data(7);
--		  o_data_parallel(2)      <=  r_rx_data(5);     --   r_rx_data(6);
--		  o_data_parallel(3)      <=  r_rx_data(4);      --  r_rx_data(5);
--		  o_data_parallel(4)      <=  r_rx_data(3);      --  r_rx_data(4);
--		  o_data_parallel(5)      <=  r_rx_data(2);       -- r_rx_data(3);
--		  o_data_parallel(6)      <=  r_rx_data(1);        --r_rx_data(2);
--        o_data_parallel(7)      <=  r_rx_data(0);  --      r_rx_data(1);
       -- o_data_parallel(15 downto 8)      <=  r_rx_data(8 to 15);  --      r_rx_data(1);
		  
		  
		  o_data_fb    <= r_rx_data_fb(16 downto 1);
        valid_data   <= '1';
				rd_cnt   <=  0;


      when others               =>  -- ST_RESET
        r_rx_data      <= (others=>'0');--r_rx_data;
		  r_rx_data_fb   <= (others=>'0');--r_rx_data;

		      valid_data <= '0';

    end case;
  end if;
end process p_state_rx_in;


p_counter_clock : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    r_counter_clock            <= 0;
    r_sclk_rise                <= '0';
    r_sclk_fall                <= '0';
  elsif(rising_edge(i_clk)) then
    if(r_counter_clock_ena='1') then  -- sclk = '1' by default 
      if(r_counter_clock=CLK_DIV-1) then  -- firse edge = fall
        r_counter_clock            <= r_counter_clock + 1;
        r_sclk_rise                <= '0';
        r_sclk_fall                <= '1';
      elsif(r_counter_clock=(CLK_DIV*2)-1) then
        r_counter_clock            <= 0;
        r_sclk_rise                <= '1';
        r_sclk_fall                <= '0';
		  
      else
        r_counter_clock            <= r_counter_clock + 1;
        r_sclk_rise                <= '0';
        r_sclk_fall                <= '0';
      end if;
    else
      r_counter_clock            <= 0;
      r_sclk_rise                <= '0';
      r_sclk_fall                <= '0';
    end if;

  end if;
end process p_counter_clock;


process(i_clk)
begin
if rising_edge(i_clk) then
 if end_rx  =  (len_frame_byt - 1) then
   if word_length_bits = X"08" then
	   if fall_count = X"12" then
		  sob_enable <= '1';
		  else
		   sob_enable <= '0';
		  end if;
	 elsif word_length_bits = X"16" then
	    if fall_count = X"20" then
		   sob_enable <= '1';
		  else
		   sob_enable <= '0';
		  end if;	  
    end if;
 else
   sob_enable <= '0';
 end if;
end if;
end process;



end rtl;