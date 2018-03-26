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

signal sixteenzero, sixteenone, sixteentwo, sixteenthree : unsigned(3 downto 0);


begin
--assigning inputs
sixteenzero <= hexin(3 downto 0);
sixteenone	<= hexin(7 downto 4);
sixteentwo	<= hexin(11 downto 8);
sixteenthree	<=hexin(15 downto 12);


	process(all)
		variable deczero, decone, dectwo, decthree: unsigned(7 downto 0) := to_unsigned(0,8);
		
		begin	
			if (sixteenzero > 9) then
				decone := decone+1;
				deczero := sixteenzero-10+deczero;
				--checking for overflows
				if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
			else
				deczero := "0000"&sixteenzero;
			end if;
			
-- check the next bit of 16			
			if(sixteenone*16 > 200) then
				dectwo:= dectwo+2;
				
				if (sixteenone*16>=250) then
					decone:=decone+9;
					--checking for overflows
						if (decone>9) then
							dectwo := dectwo+1;
							decone := to_unsigned(0,decone'length);
							if (dectwo>9) then 
								decthree := decthree+1;
								dectwo := to_unsigned(0,dectwo'length);
							end if;
						end if;
					deczero:= sixteenone*16-250+deczero;
				--looping for all cases of multiples of 16				
				elsif (sixteenone*16 >=(4*10+200)) then
					decone:=decone+4;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-4*10-200+deczero;
				
				elsif (sixteenone*16 >=(3*10+200)) then
					decone:=decone+3;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-3*10-200+deczero;

				elsif (sixteenone*16 >=(2*10+200)) then
					decone:=decone+2;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-2*10-200+deczero;

				elsif (sixteenone*16 >=(1*10+200)) then
					decone:=decone+1;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-1*10-200+deczero;

				elsif (sixteenone*16 >=(0*10+200)) then
					decone:=decone+0;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-0*10-200+deczero;
				end if;

				
				
				
			
			elsif (sixteenone*16 > 100) then
				dectwo:= dectwo+1;
				
				
				if (sixteenone*16>=190) then
					decone:=decone+9;
					--checking for overflows
						if (decone>9) then
							dectwo := dectwo+1;
							decone := to_unsigned(0,decone'length);
							if (dectwo>9) then 
								decthree := decthree+1;
								dectwo := to_unsigned(0,dectwo'length);
							end if;
						end if;
					deczero:= sixteenone*16-190+deczero;
				--looping for all cases of multiples of 16				
				elsif (sixteenone*16 >=(8*10+100)) then
					decone:=decone+8;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-8*10-100+deczero;

				elsif (sixteenone*16 >=(7*10+100)) then
					decone:=decone+7;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-7*10-100+deczero;

				elsif (sixteenone*16 >=(6*10+100)) then
					decone:=decone+6;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-6*10-100+deczero;

				elsif (sixteenone*16 >=(5*10+100)) then
					decone:=decone+5;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-5*10-100+deczero;

				elsif (sixteenone*16 >=(4*10+100)) then
					decone:=decone+4;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-4*10-100+deczero;

				elsif (sixteenone*16 >=(3*10+100)) then
					decone:=decone+3;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-3*10-100+deczero;

				elsif (sixteenone*16 >=(2*10+100)) then
					decone:=decone+2;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-2*10-100+deczero;

				elsif (sixteenone*16 >=(1*10+100)) then
					decone:=decone+1;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-1*10-100+deczero;

				elsif (sixteenone*16 >=(0*10+100)) then
					decone:=decone+0;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-0*10-100+deczero;
				end if;

		

			
			else
			
				if (sixteenone*16>=90) then
					decone:=decone+9;
					--checking for overflows
						if (decone>9) then
							dectwo := dectwo+1;
							decone := to_unsigned(0,decone'length);
							if (dectwo>9) then 
								decthree := decthree+1;
								dectwo := to_unsigned(0,dectwo'length);
							end if;
						end if;
					deczero:= sixteenone*16-90+deczero;
				--looping for all cases of multiples of 16
				
				elsif (sixteenone*16 >=(8*10)) then
					decone:=decone+8;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-8*10+deczero;

				elsif (sixteenone*16 >=(7*10)) then
					decone:=decone+7;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-7*10+deczero;

				elsif (sixteenone*16 >=(6*10)) then
					decone:=decone+6;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-6*10+deczero;
	
				elsif (sixteenone*16 >=(5*10)) then
					decone:=decone+5;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-5*10+deczero;
			
				elsif (sixteenone*16 >=(4*10)) then
					decone:=decone+4;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-4*10+deczero;
		
				elsif (sixteenone*16 >=(3*10)) then
					decone:=decone+3;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-3*10+deczero;
			
				elsif (sixteenone*16 >=(2*10)) then
					decone:=decone+2;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-2*10+deczero;

				elsif (sixteenone*16 >=(1*10)) then
					decone:=decone+1;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-1*10+deczero;

				elsif (sixteenone*16 >=(0*10)) then
					decone:=decone+0;
					if (decone>9) then
						dectwo := dectwo+1;
						decone := to_unsigned(0,decone'length);
						if (dectwo>9) then 
							decthree := decthree+1;
							dectwo := to_unsigned(0,dectwo'length);
						end if;
					end if;
					deczero:= sixteenone*16-0*10+deczero;
				
			end if;
			
			
			end if;
			
			--assigning outputs
		decout(3 downto 0) <=deczero(3 downto 0);
		decout(7 downto 4) <=decone(3 downto 0);
		decout(11 downto 8) <= dectwo(3 downto 0);
		decout(15 downto 12) <= decthree(3 downto 0);	
	end process;
	
end;
			