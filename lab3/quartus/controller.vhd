library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	generic(command_list : integer :=3;
			-- amount of time to Clear Screen (Clear Screen Time)
				CST : integer := 19200;
				y_coordinate : integer:= 7;
				x_coordinate : integer:= 8);
   port(clk : in std_logic;
		 command: in std_logic_vector (command_list-1 downto 0);
		 reset : in std_logic;
		 position: out std_logic_vector (x_coordinate + y_coordinate-1 downto 0);
		 colour_out: out std_logic_vector (2 downto 0)
		 
  );
end controller;

architecture statesof of controller is
	
	type state is (clear, blue, teal, green, yellow, white, purple, red, ready);
	signal Current_State : state;
	signal command_hold : state;
	--tells the controller to hold in current state because in the middle of command for certain time
	signal in_command : std_logic;
	-- can hold 32787 clk cycles (clear screen takes 19200)
	signal state_hold_length : unsigned(14 downto 0);
	
	
	
	--position and colour
	signal x      : unsigned(x_coordinate-1 downto 0);
	signal y      : unsigned(y_coordinate-1 downto 0);
	signal colour : std_logic_vector(2 downto 0);
	
	begin
	
	process(reset)
		begin
			if(rising_edge(reset))then 
				Current_State <= clear;
			end if;
	end process;
	
	process (all)
		begin
			case command is
				when "000" =>
					Current_State <= clear;
				when "001" =>
					Current_State <= blue;
			end case;
	end process;	
	
	process (all)
		begin
		
		if (not(in_command)) then
		
			case (Current_State) is
				when clear => 
					command_hold <= clear;
					in_command <= '1';
					state_hold_length <= to_unsigned(CST,state_hold_length'length);
					
				when blue =>
					command_hold <= blue;
					in_command <= '1';
					state_hold_length <= to_unsigned(CST,state_hold_length'length);
					
				when others => 
					command_hold <= ready;
					in_command <= '0';
					plot <= '0';
					
			end case;
		end if;
	end process;
	
	process (clk)
		begin
		
		if(rising_edge(clk)) then
			case(command_hold) is
			--if in ready waits for next command	
				when ready =>
					in_command <= '0';
					command_hold <= ready;
					plot <= '0';
					
			--checks if length of time needed for the command to finish has expired
				when others => 
					if (state_hold_length < 1) then
						in_command <= '0';
						command_hold <= ready;
					else
						state_hold_length <= state_hold_length-1;
					end if;			
					
				end case;
			end if;
			
		if (falling_edge(clk)) then
			case(command_hold) is
			--starts clearing the screen (this is on falling edge due the responsiveness from the vga adapter	
				when clear =>				
					if (y > 120) then
						plot <= '1';
						x <= x+1;
						y <= to_unsigned(0,y'length);
						colour <= "111";
					else
						plot <= '1';
						y <= y+1;
						colour <= "111";
					end if;
			--sets the pixels for a blue circle	
				when blue =>
	
				when others =>
					in_command <='0';
					command_hold <= ready;
					plot <= '0';
				
			end case;
		end if;
		
	end process;
	
END;
					
					
					
					process (CLOCK_50, KEY(3))
	begin
		
		if(falling_edge(CLOCK_50)) then
			if (y > 120) then
				plot <= '1';
				x <= x+1;
				y <= to_unsigned(0,y'length);
				colour <= std_logic_vector(to_unsigned((to_integer(x) mod integer(8)),colour'length));
			else
				plot <= '1';
				y <= y+1;
				colour <= std_logic_vector(to_unsigned((to_integer(x) mod integer(8)),colour'length));
			end if;
		end if;
		
		if (KEY(3)) then
			plot <= '0';
			y<= to_unsigned(0,y'length);
			x<= to_unsigned(0,x'length);
		end if;
	
	end process;
	

	