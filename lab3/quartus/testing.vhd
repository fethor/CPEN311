		if(falling_edge(CLOCK_50)) then
			if not(cleared) then
				if (y > 120) then
					plot <= '1';
					x <= x+1;
					y <= to_unsigned(0,y'length);
					colour <= "111";
					if (x > 159) then
						cleared <= '1';
					end if;
				else
					plot <= '1';
					y <= y+1;
					colour <= "111";
				end if;
				
			else 
				circle_enable <= '1';
				in_command <= '1';			
			end if;
			
		
		
		if (KEY(3)) then
			plot <= '0';
			cleared <= '0';
			in_command <= '0';
			y<= to_unsigned(0,y'length);
			x<= to_unsigned(0,x'length);
		end if;