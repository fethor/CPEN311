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
	
	
	component hex2dec is
		port (hexin: in unsigned(15 downto 0);
			decout: out unsigned(15 downto 0));	
	end component;

--TYPES	
	
	type input_split is record
		bet_amount : unsigned(2 downto 0);
		bet_modifier: unsigned(3 downto 0);
		bet_target: unsigned (5 downto 0);
	end record;
	
-- SIGNALS
	signal split: input_split;
	signal slow_clock: std_logic;
	signal moneyzzz, decimalOut, spin_decimal, bet_decimal: unsigned (15 downto 0);
	signal moneyzzz_latched: unsigned (15 downto 0):= to_unsigned(32,16); --:= "0000000000100000";
	signal result, result_latched, target_latched: unsigned (5 downto 0);
	signal modifier_latched: unsigned (3 downto 0);
	signal amount_latched, amount: unsigned (2 downto 0);
	signal win_type: unsigned (2 downto 0);

	
-- BEGINNING OF THE PROCESS
	begin
	split.bet_amount <= unsigned(SW(12 downto 10));
	split.bet_modifier <= unsigned(SW(9 downto 6));
	split.bet_target <= unsigned(SW(5 downto 0));
	LEDG(0) <= win_type(0);
	LEDG(1) <= win_type(1);
	LEDG(2) <= win_type(2);
	slow_clock <= key(0);

--MONEY DISPLAY
	HexDecConverter: hex2dec port map(hexin => moneyzzz,
													decout => decimalOut);

	Hexzero: digit7seg port map(digit => decimalOut(3 downto 0),
											seg7 => HEX0);
	Hexone: digit7seg port map(digit => decimalOut(7 downto 4),
											seg7 => HEX1);
	Hextwo: digit7seg port map(digit => decimalOut(11 downto 8),
											seg7 => HEX2);
	Hexthree: digit7seg port map(digit => decimalOut(15 downto 12),
											seg7 => HEX3);
											
--RESULT DISPALY
	HexDecConverter2: hex2dec port map(hexin => "0000000000" & result_latched,
														decout => spin_decimal);	
	
	Hexsix: digit7seg port map(digit => spin_decimal(3 downto 0),
											seg7 => HEX6);
	Hexseven: digit7seg port map(digit => spin_decimal (7 downto 4),
											seg7 => HEX7);											
											

--SPIN WHEEL
	Spinner: spinwheel port map (fast_clock => clock_27,
											resetb => key(1),
											spin_result => result);		
											
--WIN MODULE
	Winner: win port map (spin_result_latched =>result_latched,
									bet_target => target_latched,
									bet_modifier => modifier_latched,
									win_straightup => win_type(0),
									win_split => win_type(1),
									win_corner => win_type(2));	

--BALANCE MODULE
	Balancing: new_balance port map (money => moneyzzz_latched,
												bet_amount=> amount_latched,
												win_straightup => win_type(0),
												win_split => win_type(1),
												win_corner => win_type(2),
												new_money => moneyzzz);
										
--display the bet number
	HexDecConverter3: hex2dec port map (hexin => "0000000000"&unsigned(SW (5 downto 0)),
													decout => bet_decimal);
	
	Hexfour: digit7seg port map(digit => bet_decimal(3 downto 0),
											seg7 => HEX4);
	Hexfive: digit7seg port map(digit => bet_decimal(7 downto 4),
											seg7 => HEX5);
											
											
	process (slow_clock) 
	begin 
		if rising_edge(slow_clock) then
			amount_latched <= split.bet_amount;
			target_latched <= split.bet_target;
			result_latched <= result;
			modifier_latched <= split.bet_modifier;
			if (key(1)) then
			moneyzzz_latched <= moneyzzz;
			end if;
	
		end if;
		--so that when pressing reset the value in the bank is actually 32
		if not(key(1))then
			moneyzzz_latched <= to_unsigned(32,moneyzzz_latched'length);
			amount_latched <= to_unsigned(0,amount_latched'length);
			target_latched <= to_unsigned(0,target_latched'length);
			result_latched <= to_unsigned(0,result_latched'length);
			modifier_latched <= to_unsigned(0,modifier_latched'length);
			
		
		end if;
	
	end process;
	
	
	

END;
