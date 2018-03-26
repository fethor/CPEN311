library ieee;
use ieee.std_logic_1164.all;

entity Lab1_SM_tb is
end entity;

architecture rtl of Lab1_SM_tb is
	component Task3 
		port (clk : in std_logic;  
         resetb : in std_logic; 
         skip : in std_logic; 
         hex : out std_logic_vector(6 downto 0) 
   );
	end component;
	
	signal clk, skip, resetb : std_logic;
	signal hex: std_logic_vector (6 downto 0);

begin
  dut: Task3 port map (clk, resetb, skip, hex);
    
    process
      begin
        
        clk <= '0';
        wait for 5 ps;
  -- test reset button to state 'H'
          resetb <= '0';
          clk <= '1';
          skip <= '0';
        
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
          resetb <= '0';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps;
      
      clk <= '0';
        wait for 5 ps; 
      
          resetb <= '0';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
          resetb <= '0';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
-- Run through the full name once

      resetb <= '1';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
         clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
          clk <= '0';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      resetb <= '1';
          clk <= '1';
          skip <= '0';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
-- Run through with skipping letters and single reset phase
      
      resetb <= '0';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
      
      resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
        resetb <= '1';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
        
-- final reset

resetb <= '0';
          clk <= '1';
          skip <= '1';
          
      wait for 5 ps; 
      
      clk <= '0';
        wait for 5 ps;
      
    end process;
  end rtl;
        
	