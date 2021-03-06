LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

entity hex2dec_tb is
end hex2dec_tb;

architecture behave of hex2dec_tb is

signal hexin, decout: unsigned (15 downto 0);

component hex2dec is
	port (hexin: in unsigned(15 downto 0);
			decout: out unsigned(15 downto 0)
			);	
	end component;

begin
DUT: hex2dec port map (hexin => hexin,
                        decout => decout);
      process begin
          hexin <= "0000000000000000";
          
          wait for 5 ps;
          
          hexin <= "0000000000001111";
          
          wait for 5 ps;
          
          hexin <= "0000000011110000";
          
          wait for 5 ps;
          
          hexin <= "0000000000000111";
          
          wait for 5 ps;
          
          hexin <= "0000000000010000";
          
 
          wait for 5 ps;
          
          hexin <= "0000000000000000";

          wait for 5 ps;
end process;

END;
          
          
