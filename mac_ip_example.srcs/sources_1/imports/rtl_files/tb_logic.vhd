--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:56:31 03/13/2018
-- Design Name:   
-- Module Name:   D:/C_Band_VAR_CLK/tb_logic.vhd
-- Project Name:  TOP_CX_Band
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: test_logic
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_logic IS
END tb_logic;
 
ARCHITECTURE behavior OF tb_logic IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT test_logic
    PORT(
         CLK_3MZH : IN  std_logic;
         rst : IN  std_logic;
         S_START_COUNT : IN  std_logic;
         oo : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_3MZH : std_logic := '0';
   signal rst : std_logic := '1';
   signal S_START_COUNT : std_logic := '0';

 	--Outputs
   signal oo : std_logic;

   -- Clock period definitions
   constant CLK_3MZH_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: test_logic PORT MAP (
          CLK_3MZH => CLK_3MZH,
          rst => rst,
          S_START_COUNT => S_START_COUNT,
          oo => oo
        );

   -- Clock process definitions
   CLK_3MZH_process :process
   begin
		CLK_3MZH <= '0';
		wait for CLK_3MZH_period/2;
		CLK_3MZH <= '1';
		wait for CLK_3MZH_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst  <= '1';
		S_START_COUNT  <=  '0';
      wait for 100 ns;	
rst  <= '0';
		S_START_COUNT  <=  '0';

      wait for CLK_3MZH_period*10;
		S_START_COUNT  <=  '1';

      -- insert stimulus here 

      wait;
   end process;

END;
