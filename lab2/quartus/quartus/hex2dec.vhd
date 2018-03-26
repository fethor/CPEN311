LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

entity hex2dec is
	port (hexin: in unsigned(15 downto 0);
			decout: out unsigned(15 downto 0)
			);	
	end hex2dec;

architecture Processing of hex2dec is

begin


	process(all)
		variable deczero, decone, dectwo, decthree: unsigned(7 downto 0);
		
		begin	
		deczero := to_unsigned(0,8);
		decone := to_unsigned(0,8);
		dectwo := to_unsigned(0,8);
		decthree := to_unsigned(0,8);
		
		if hexin(0)='1' then
			deczero := deczero+1;
		end if;
		
		if hexin(1)='1' then
			deczero := deczero+2;
		end if;
		
		if hexin(2)='1' then
			deczero := deczero+4;
		end if;
		
		if hexin(3)='1' then
			deczero := deczero+8;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
		end if;
		
		if hexin(4)='1' then
			deczero := deczero+6;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+1;
		end if;
		
		if hexin(5)='1' then
			deczero := deczero+2;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+3;
		end if;
		
		if hexin(6)='1' then
			deczero := deczero+4;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+6;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
		end if;
		
		if hexin(7)='1' then
			deczero := deczero+8;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+2;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+1;
		end if;
		
		if hexin(8)='1' then
			deczero := deczero+6;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+5;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+2;
		end if;
		
		if hexin(9)='1' then
			deczero := deczero+2;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+1;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+5;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
		end if;
		
		if hexin(10)='1' then
			deczero := deczero+4;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+2;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+0;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+1;
		end if;
		
		if hexin(11)='1' then
			deczero := deczero+8;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+4;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+0;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+2;
		end if;
		
		if hexin(12)='1' then
			deczero := deczero+6;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+9;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+0;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+4;
		end if;
		
		if hexin(13)='1' then
			deczero := deczero+2;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+9;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+1;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+8;
		end if;
		
		if hexin(14)='1' then
			deczero := deczero+4;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+8;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+3;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+16;
		end if;
		
		if hexin(15)='1' then
			deczero := deczero+8;
			if (deczero > 9) then
				decone := decone+1;
				deczero:= deczero-10;
			end if;
			decone := decone+6;
			if (decone >9) then
				dectwo := 1+dectwo;
				decone:= decone-10;
			end if;
			dectwo := dectwo+7;
			if (dectwo >9) then
				decthree := 1+decthree;
				dectwo:= dectwo-10;
			end if;
			decthree := decthree+32;
		end if;
	
	
		--assigning outputs
		decout(3 downto 0) <=deczero(3 downto 0);
		decout(7 downto 4) <=decone(3 downto 0);
		decout(11 downto 8) <= dectwo(3 downto 0);
		decout(15 downto 12) <= decthree(3 downto 0);	
	
	
	end process;
	
end;
			