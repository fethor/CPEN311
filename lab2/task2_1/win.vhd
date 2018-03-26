LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  Steve Wilton, Jan 2016  
--
--  This is the skeleton for the win subblock.  This block determines
--  whether the bet is a winner, and if so, whether it should
--  pay out x35 (if it is a straight up bet), x17 (a split), 
--  or x8 (a corner bet).  At most one of the outputs win_straightup,
--  win_split or win_corner will go high (if none of them go high, 
--  the bet is a loser).
--
--  This is a purely combinational block.  There is no clock.
--
---------------------------------------------------------------

ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet_target : in unsigned(5 downto 0); -- target number for bet
             bet_modifier : in unsigned(3 downto 0); -- as described in the handout
             win_straightup : out std_logic;  -- whether it is a straight-up winner
             win_split : out std_logic;  -- whether it is a split bet winner
             win_corner : out std_logic); -- whether it is a corner bet winner
END win;


ARCHITECTURE behavioural OF win IS
BEGIN
  -- your code goes here
END;
