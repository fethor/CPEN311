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

component circler is
   port(clk : in std_logic;
		 enable: in std_logic;
		 reset : in std_logic;
		 radius: in std_logic_vector (5 downto 0);
		 position_x: out std_logic_vector (8 downto 0);
		 position_y: out std_logic_vector (7 downto 0);
		 plot: out std_logic
	);
end component;


begin

process (all)
	begin
		
		case command_list is 
		
			when "01" =>
				



