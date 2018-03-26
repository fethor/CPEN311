LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  Steve Wilton, Jan 2016.  
--  Skeleton file for new_balance block
--
---------------------------------------------------------------


ENTITY new_balance IS
  PORT(money : in unsigned(15 downto 0);
       bet_amount : in unsigned(2 downto 0);
       win_straightup : in std_logic;
       win_split : in std_logic;
       win_corner : in std_logic;
       new_money : out unsigned(15 downto 0));
END new_balance;


ARCHITECTURE behavioural OF new_balance IS

BEGIN



	MAJORproc: process (all)
					variable change: unsigned(15 downto 0);
						begin
						--controls for the amount of money returned when winning
							if(money >= bet_amount) then
							change := money - bet_amount;
							
							else
							change := to_unsigned(0,change'length);
							end if;
							
								if (win_straightup) then
									change := change+ to_unsigned(35,change'length-bet_amount'length)*bet_amount+bet_amount;
								
								elsif (win_split) then
									change := change+ to_unsigned(17,change'length-bet_amount'length)*bet_amount+ bet_amount;
								
								elsif (win_corner) then
									change := change+ to_unsigned(8,change'length-bet_amount'length)*bet_amount+ bet_amount;
							
								else
									change := change;
								end if;
							new_money <= change;
							
						end process;


END;
