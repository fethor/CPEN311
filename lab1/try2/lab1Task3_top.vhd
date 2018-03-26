library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FSMC_declerations.all;
use work.adder92_decl.all;

entity task3_top is
   port (KEY: in std_logic_vector(3 downto 0);  -- push-button switches
         SW : in std_logic_vector(17 downto 0);  -- slider switches
			LEDR : buffer std_logic_vector (17 downto 0);
         CLOCK_50: in std_logic;                 -- 50MHz clock input
			CLOCK_27: in std_logic;
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, Hex7
			: out std_logic_vector(6 downto 0) -- output to drive all the digits
			--TD_RESET: out std_logic
	 
   );     
end task3_top;

architecture structural of task3_top is
	
   signal slow_clock, slower_clock : std_logic;
   signal count50 : unsigned(29 downto 0) := (others => '0');
	signal count27 : unsigned(29 downto 0) := (others => '0');
	signal test: std_logic_vector (17 downto 0) := (others => '0');
	signal large, small : unsigned(7 downto 0);
begin	
	--TD_RESET <= '1';
	process(CLOCK_27)
		begin	
			if rising_edge (CLOCK_27) then
			--count27 <= count27 + 1;
			count27 <= count27+  large;
			end if;
		end process;
		
		

   PROCESS (CLOCK_50)	
    BEGIN
        if rising_edge (CLOCK_50) THEN 
				
            count50 <= count50 +small;
				--count27 <= count27 +large;
				
        end if;

    END process;
    slow_clock <= count50(28);   -- the output is the MSB of the counter
    slower_clock <= count27(28);   -- the output is the MSB of the counter
	 
	
	 
	 --turn off the light because way too bright LOL
HEX1 <= (others =>'1');
HEX2 <= (others =>'1');
HEX4 <= (others =>'1');
HEX5 <= (others =>'1');
HEX6 <= (others =>'1');
HEX7 <= (others =>'1');


StateMAchine1: Task3 port map(clk => slow_clock,
         resetb => key(0),
         skip => sw(0),
         hex =>hex0
   );
SM2: Task3 port map(clk => slower_clock,
         resetb => key(0),
         skip => sw(1),
         hex =>hex3
   );
	
adderlarge: adder92 port map (SW => SW(17 downto 10),
										output => large);
										
addersmall: adder92 port map (SW => SW(9 downto 2),
										output => small);
end structural;
