LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is a FIR filter, as described in the lab handout.
-- It is written as an 8-tap filter, although it can easily be changed
-- for more taps. 

ENTITY fir8 IS 
   PORT ( CLOCK_50, valid: in std_logic;
          stream_in : in std_logic_vector(23 downto 0);
          stream_out : out std_logic_vector(23 downto 0));
end fir8;

ARCHITECTURE behaviour of fir8 is
   
	signal hold_eight, hold_five, hold_four, hold_one, hold_seven, hold_six, hold_three, hold_two : signed (23 downto 0);
	
	
begin	
	process (cloCK_50) 
	begin
	
	if (rising_edge(cloCK_50)) then
		if (valid = '1') then
			if (stream_in(23) = '0') then
				hold_one <= "000" & signed(stream_in(23 downto 3));
				hold_two <= hold_one;
				hold_three <= hold_two;
				hold_four <= hold_three;
				hold_five <= hold_four;
				hold_six <= hold_five;
				hold_seven <= hold_six;
				hold_eight <= hold_seven;
			else
				hold_one <= "111" & signed(stream_in(23 downto 3));
				hold_two <= hold_one;
				hold_three <= hold_two;
				hold_four <= hold_three;
				hold_five <= hold_four;
				hold_six <= hold_five;
				hold_seven <= hold_six;
				hold_eight <= hold_seven;
			end if;	
		end if;
	stream_out <= std_logic_vector(hold_one+hold_two+hold_three+hold_four+hold_five+hold_six+hold_seven+hold_eight);
	end if;
	
	end process;	
end;
