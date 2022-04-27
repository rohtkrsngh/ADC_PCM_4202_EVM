library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity clk_gen_module is
 port (
  i_clk                      : in  std_logic;
  i_rstb                     : in  std_logic;
  change_clk                 : in std_logic;  
  CLK_DIV                    : in std_logic_vector(4 downto 0);
  o_sclk                     : out std_logic

  );
end clk_gen_module;
architecture rtl of clk_gen_module is
type t_spi_controller_fsm is (
                          ST_RESET   ,
                          ST_TX_RX   ,
                          ST_END     );
								  
	type delay_fsm is (
                          ST_R   ,
                          ST_T   ,
                          ST_E     );	
signal pre,nxt: 	delay_fsm;							  

	signal 	so_sclk : std_logic:='0';						  
signal CLK_DIVs : integer range 0 to 64;
signal CLK_DIVs1 : integer range 0 to 64;

signal CLK_DIVs2 : integer range 0 to 64;

signal r_counter_clock        : integer range 0 to 64;
signal r_sclk_rise            : std_logic;
signal r_sclk_fall            : std_logic;
signal r_counter_clock_ena    : std_logic;
signal w_tc_counter_data      : std_logic;
signal r_st_present           : t_spi_controller_fsm;
signal w_st_next              : t_spi_controller_fsm;
signal r_tx_start             : std_logic:='0';  -- start TX on serial line

signal en_cnt_d              : std_logic:='0';  -- data to sent
signal cnt_value : std_logic_vector(3 downto 0):=(others=>'0');
begin
w_tc_counter_data  <= '0' when(change_clk='0') else '1';
 o_sclk<=so_sclk;
--------------------------------------------------------------------
CLK_DIVs2 <= to_integer(unsigned(CLK_DIV));

--process(i_clk) --,i_rstb updated
--begin
--  if(rising_edge(i_clk)) then
--    if change_clk='1' then
--	   CLK_DIVs1<=CLK_DIVs;
--		else
--	   CLK_DIVs1<=CLK_DIVs1;
--		end if;
--  end if;
--end process ;

--process(i_clk) --,i_rstb updated
--begin
--  if(rising_edge(i_clk)) then
--   if cnt_value =X"A" then
--	   CLK_DIVs2<=CLK_DIVs;
--		else
--	   CLK_DIVs2<=CLK_DIVs2;
--  end if;
--  end if;
--end process 


p_state : process(i_clk,i_rstb)  --,i_rstb  updated 17 july
begin
  if(i_rstb='1') then
    r_st_present            <= ST_RESET;
  elsif(rising_edge(i_clk)) then
    r_st_present            <= w_st_next;
  end if;
end process p_state;
p_comb : process(
                 r_st_present                       ,
                 w_tc_counter_data                  ,
                 r_tx_start                         ,
                 r_sclk_rise                        ,
                 r_sclk_fall                         )
begin
  case r_st_present is
    when  ST_TX_RX      => 
      if       (w_tc_counter_data='1') then  w_st_next  <= ST_RESET       ; --and (r_sclk_rise='1') 
      else                                    w_st_next  <= ST_TX_RX     ;
      end if;
    when  ST_END      => 
      if(r_sclk_rise='1') then
        w_st_next  <= ST_RESET    ;  
      else
        w_st_next  <= ST_END    ;  
      end if;
    when  others            =>  -- ST_RESET
      if(r_tx_start='1') then   w_st_next  <= ST_TX_RX ;
      else                      w_st_next  <= ST_RESET ;
      end if;
  end case;
end process p_comb;


p_state_clk_out : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    
     
    r_counter_clock_ena  <= '0';
    so_sclk               <= '0';
  elsif(rising_edge(i_clk)) then
    case r_st_present is
      when ST_TX_RX         =>
        r_counter_clock_ena  <= '1';
        if(r_sclk_fall='1') then
          so_sclk               <= '0';
          
          
        elsif(r_sclk_rise='1') then
          so_sclk               <= '1';
        end if;
      when ST_END          =>
        r_counter_clock_ena  <= '1';
      
      when others               =>  -- ST_RESET
        r_counter_clock_ena  <= '0';
        so_sclk               <= '0';
    end case;
  end if;
end process p_state_clk_out;





p_counter_clock : process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
    r_counter_clock            <= 0;
    r_sclk_rise                <= '0';
    r_sclk_fall                <= '0';
  elsif(rising_edge(i_clk)) then
    if(r_counter_clock_ena='1') then  -- sclk = '1' by default 
      if(r_counter_clock=CLK_DIVs2-1) then  -- firse edge = fall
        r_counter_clock            <= r_counter_clock + 1;
        r_sclk_rise                <= '1';
        r_sclk_fall                <= '0';
		--  wr_cnt<= wr_cnt+1;
		 -- rd_cnt<=rd_cnt+1;
      elsif(r_counter_clock=(CLK_DIVs2*2)-1) then
        r_counter_clock            <= 0;
        r_sclk_rise                <= '0';
        r_sclk_fall                <= '1';
		  
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

process(i_clk,i_rstb) --,i_rstb updated
begin
  if(i_rstb='1') then
  pre<=st_r;
   elsif(rising_edge(i_clk)) then
    pre            <= nxt;
  end if;
end process ;
  

 process(change_clk,nxt,en_cnt_d,cnt_value,r_tx_start) --,i_rstb updated
begin
case pre is
when st_r =>
  					r_tx_start<='0';

  if(change_clk='1') then
     nxt<=st_t;
	  en_cnt_d<='1';
	  else
	       nxt<=st_r;
			 	  en_cnt_d<='0';

			 end if;
when st_t =>
       if cnt_value =X"E" then
         	r_tx_start<='1';
                  nxt<=st_e;
						  en_cnt_d<='0';
	
					else
					r_tx_start<='0';
                  nxt<=st_t;
							  en_cnt_d<='1';

						end if;
  when st_e =>
  	  en_cnt_d<='0';

									r_tx_start<='0';
	       nxt<=st_r;
end case;
end process;

process(i_clk) --,i_rstb updated
begin
  if(rising_edge(i_clk)) then
    if en_cnt_d='1' then
	   cnt_value<=cnt_value+1;
		else
		cnt_value<=X"0";
		end if;
  end if;
end process ;

end rtl;