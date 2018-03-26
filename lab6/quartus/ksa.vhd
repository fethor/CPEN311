library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity lab6_top is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end lab6_top;

-- Architecture part of the description

architecture rtl of lab6_top is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, 
                       state_fill,						
   	 					  state_done,
							  swap_array_read_1,
							  swap_array_read_2,
							  swap_array_read_3,
							  swap_array_read_4);
								
    -- These are signals that are used to connect to the memory													 
	 signal state : state_type;
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	
	 signal clk : std_logic;
	 signal secret_key : std_LOGIC_VECTOR (23 downto 0);

	 begin
	    -- Include the S memory structurally
	 clk <= cloCK_50;
	 secret_key <= "000000"&sw(17 downto 0);
	 
    u0: s_memory port map ( address, clk, data, wren, q);
		
		
       -- write your code here.  As described in Slide Set 14, this 
       -- code will drive the address, data, and wren signals to
       -- fill the memory with the values 0...255
         
       -- You will be likely writing this is a state machine. Ensure
       -- that after the memory is filled, you enter a DONE state which
       -- does nothing but loop back to itself.  

		process (clk, key(3))
		variable i : unsigned (7 downto 0) := to_unsigned(0,8);
		variable j : unsigned (23 downto 0) := to_unsigned(0,24);
		variable hold_data, hold_data2 : std_logic_vector (7 downto 0);
		variable Mod_math, secret_value: integer;
		variable wtf : std_LOGIC_VECTOR(1 downto 0);
		
		begin
		if(key(3)='1') then
			state <= state_init;
			i := to_unsigned(0,i'length);
			j := to_unsigned(0,j'length);
			
			wren <= '0';
			
		elsif (rising_edge(clk)) then
			case state is
				when state_init =>
					i := to_unsigned(0,i'length);
					state <= state_fill;
					wren <= '1';
				
				when state_fill =>
					address <= std_LOGIC_VECTOR(i);
					data <= std_logic_vector(i);
					
					i := i +1;
					if i = 255 then
						state <= swap_array_read_1;
					   i := to_unsigned(0,i'length);
						j := to_unsigned(0,j'length);
						wren <= '0';
					end if;
					
				when swap_array_read_1 => 
					address <= std_logic_vector(i);
					mod_math := to_integer(i) mod 23;
					
			
					for a in 0 to 23 loop
					if mod_math = a then
						wtf := '0'&secret_key(a);
						secret_value := to_integer(unsigned(wtf));
					end if;
					end loop;
					
					state <= swap_array_read_2;
					
				when swap_array_read_2 =>
					hold_data := q;
					j := j + unsigned(q) + to_unsigned(secret_value,j'length);
					mod_math := to_integer(j) mod 256;
					address <= std_logic_vector(to_unsigned(mod_math,address'length));
					wren <= '1';
					state <= swap_array_read_3;
					
				when swap_array_read_3 =>
					hold_data2 := q;
					address <= std_LOGIC_VECTOR(i);
					data <= hold_data;
					state <= swap_array_read_4;
					
				when swap_array_read_4 =>
					address <= std_logic_vector(to_unsigned(mod_math,address'length));
					data <= hold_data2;
					i := i+1;
					if i = 255 then
						state <= state_done;
					   i := to_unsigned(0,i'length);
						j := to_unsigned(0,j'length);
						wren <= '0';
					else
						state <= swap_array_read_1;
						wren <= '0';
					end if;
				
					
					
					
				
				when state_done =>
					state <= state_done;
					
				when others => state <= state_done;
				
				end case;
			end if;
		end process;
		
		 

end RTL;


