LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

----------------------------------------------------------------------
--
--  This is the top level template for Lab 2.  Use the schematic
--  in the lab handout to guide you in creating this structural description.
--  The combinational blocks have already been designed in previous tasks,
--  and the spinwheel block is given to you.  Your task is to combine these
--  blocks, as well as add the various registers shown on the schemetic, and
--  wire them up properly.  The result will be a roulette game you can play
--  on your DE2.
--
-----------------------------------------------------------------------

ENTITY lab2_top IS
	PORT(   CLOCK_27 : IN STD_LOGIC; -- the fast clock for spinning wheel
		KEY : IN STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : IN STD_LOGIC_VECTOR(17 downto 0);
		LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
		HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
END lab2_top;


ARCHITECTURE structural OF lab2_top IS
--COMPONENTS
	component new_balance is
	  PORT(money : in unsigned(15 downto 0);
       bet_amount : in unsigned(2 downto 0);
       win_straightup : in std_logic;
       win_split : in std_logic;
       win_corner : in std_logic;
       new_money : out unsigned(15 downto 0));
	end component;
	
	component win is
		PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet_target : in unsigned(5 downto 0); -- target number for bet
             bet_modifier : in unsigned(3 downto 0); -- as described in the handout
             win_straightup : out std_logic;  -- whether it is a straight-up winner
             win_split : out std_logic;  -- whether it is a split bet winner
             win_corner : out std_logic); -- whether it is a corner bet winner
	end component;
	
	component spinwheel is
			PORT(
				fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
				resetb : IN  STD_LOGIC;      -- asynchronous reset
				spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
	end component;
	
	component digit7seg is
		PORT(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
			);
	end component;

--TYPES	
	
	type input_split is record
		bet_amount : unsigned(2 downto 0);
		bet_modifier: unsigned(3 downto 0);
		bet_target: unsigned (5 downto 0);
	end record;
	
-- SIGNALS
	signal split: input_split;
	
	
-- BEGINNING OF THE PROCESS
	begin
	split.bet_amount <= SW(12 downto 10);
	split.bet_modifier <= SW(9 downto 6);
	split.bet_target <= SW(5 downto 0);
	fast_clock <= clock_27;
	
	

END;
