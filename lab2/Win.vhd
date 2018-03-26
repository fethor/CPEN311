LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet_target : in unsigned(5 downto 0); -- target number for bet
             bet_modifier : in unsigned(3 downto 0); -- as described in the handout
             win_straightup : out std_logic;  -- whether it is a straight-up winner
             win_split : out std_logic;  -- whether it is a split bet winner
             win_corner : out std_logic); -- whether it is a corner bet winner
END win;

ARCHITECTURE behavioural OF win IS

signal TL, T, TR, L, R, BL, B, BR : unsigned(5 downto 0);
signal multiplier : std_logic_vector (2 downto 0);

BEGIN

-- sets the bits for the signals to hold correct values

/*
	process (all) begin
		if (bet_modifier = "1111") then
			TL <= bet_target -4;
		elsif (bet_modifier = "1000" or bet_modifier = "1001" or bet_modifier = "1111" ) then
			T<= bet_target - 3;
		elsif (bet_modifier = "1001") then
			TR<= bet_target -2;
		elsif (bet_modifier = "1110" or bet_modifier = "1111" or bet_modifier = "1101") then
			L <= bet_target -1;
		elsif (bet_modifier = "1010" or bet_modifier = "1001" or bet_modifier = "1011") then
			R <= bet_target +1;
		elsif (bet_modifier = "1101") then
			BL <= bet_target +2;
		elsif (bet_modifier = "1100" or bet_modifier = "1101" or bet_modifier = "1011") then
			B <= bet_target +3;
		elsif (bet_modifier = "1011")then
			BR <= bet_target +4;
		else TL <= "000000";
		end if;
	end process;
	*/
	process (all) begin		
		case bet_modifier is
			when "1111" =>
				TL <= bet_target -4;
				T<= bet_target -3;
				L<= bet_target -1;
			
			when "1000" =>
				T <= bet_target-3;
			
			when "1001" =>
				T<= bet_target-3;
				TR <= bet_target -2;
				R <= bet_target +1;
			
			when "1010" =>
				R <= bet_target +1;
			
			when "1011" =>
				R <= bet_target +1;
				B <= bet_target +3;
				BR <= bet_target +4;
			
			when "1100" =>
				B <= bet_target+3;
			
			when "1101" =>
				B <=bet_target+3;
				BL <=bet_target+2;
				L <=bet_target-1;
				
			when "1110" =>
				L <=bet_target-1;
			
			when others =>
				TL <="000000";
				T <="000000";
				TR <="000000";
				L <="000000";
				R <="000000";
				BL <="000000";
				B <="000000";
				BR <="000000";
				
			end case;
		end process;
				
				
--cases for each bet modifier and how the win is determined			
	process (all) begin 
				case bet_modifier is
				
				-- first four are corner bets
					when "1111" =>
						if (TL = spin_result_latched or T = spin_result_latched 
						or L= spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "100";
						else multiplier <="000";
						end if;
					
					when "1001" =>
						if (T = spin_result_latched or TR = spin_result_latched 
						or R= spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "100";
						else multiplier <="000";
						end if;
						
					when "1101" =>
						if (BL = spin_result_latched or B = spin_result_latched 
						or L= spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "100";
						else multiplier <="000";
						end if;
						
					when "1011" =>
						if (B = spin_result_latched or BR = spin_result_latched 
						or R= spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "100";
						else multiplier <="000";
						end if;
				-- these four are for veritcal or horizontal splits	
					when "1000" =>
						if (T = spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "010";
						else multiplier <="000";
						end if;
						
					when "1010" =>
						if (R = spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "010";
						else multiplier <="000";
						end if;
						
					when "1100" =>
						if (B = spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "010";
						else multiplier <="000";
						end if;
					
					when "1110" =>
						if (L = spin_result_latched or bet_target = spin_result_latched) then
							multiplier <= "010";
						else multiplier <="000";
						end if;
						
				--big winner LOL
					when "0000" =>
						if (bet_target = spin_result_latched) then
							multiplier <= "001";
						else multiplier <="000";
						end if;
						
					when others => multiplier <="111";
						
					end case;
					
					if (bet_modifier = "1111" or bet_modifier = "1110" or bet_modifier = "1101") then
						for I in 11 downto 0 loop
							if (bet_target = 1+3*I) then
								multiplier <= "000";
							end if;
						end loop;
					end if;
					
					if (bet_modifier = "1001" or bet_modifier = "1010" or bet_modifier = "1011") then
						for I in 11 downto 0 loop
							if (bet_target = 3+3*I) then
								multiplier <= "000";
							end if;
						end loop;
					end if;
					
					if (bet_modifier = "1111" or bet_modifier = "1000" or bet_modifier = "1001") then
						for I in 2 downto 0 loop
							if (bet_target = 1+I) then
								multiplier <= "000";
							end if;
						end loop;
					end if;
					
					if (bet_modifier = "1101" or bet_modifier = "1100" or bet_modifier = "1011") then
						for I in 2 downto 0 loop
							if (bet_target = 32+I) then
								multiplier <= "000";
							end if;
						end loop;
					end if;
				
							
				end process;	
				
	
	win_straightup <= multiplier(0);
	win_split <= multiplier(1);
	win_corner <= multiplier(2);
END;
