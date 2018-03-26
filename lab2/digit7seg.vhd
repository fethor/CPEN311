LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

-----------------------------------------------------
--
--  This block will contain a decoder to decode a 4-bit number
--  to a 7-bit vector suitable to drive a HEX dispaly
--
--  It is a purely combinational block (think Pattern 1) and
--  is similar to a block you designed in Lab 1.
--
--------------------------------------------------------

ENTITY digit7seg IS
	PORT(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
	);
END;


ARCHITECTURE behavioral OF digit7seg IS
BEGIN

	process (all)
		begin
			case digit is
				--numbers 0-9
				when ("0000") => seg7<= "1000000";
				when ("0001") => seg7<= "1111001";
				when ("0010") => seg7<= "0100100";
				when ("0011") => seg7<= "0110000";
				when ("0100") => seg7<= "0011001";
				when ("0101") => seg7<= "0010010";
				when ("0110") => seg7<= "0000010";
				when ("0111") => seg7<= "1111000";
				when ("1000") => seg7<= "0000000";
				when ("1001") => seg7<= "0010000";
				
				--letters for 10 and above
				when ("1010") => seg7<= "0001000";
				when ("1011") => seg7<= "0000011";
				when ("1100") => seg7<= "1000110";
				when ("1101") => seg7<= "0100001";
				when ("1110") => seg7<= "0000110";
				when ("1111") => seg7<= "0001110";
			end case;
		end process;

END;
