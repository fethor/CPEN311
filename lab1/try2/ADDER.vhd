library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity adder92 is
	port(
		SW	: in std_logic_vector(7 downto 0);
		output	: out unsigned (7 downto 0)
	);
end entity;

architecture rtl of adder92 is
begin
	output <= unsigned(SW(7 downto 0));
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package Adder92_decl is
  component adder92 is
  port(SW	: in std_logic_vector(7 downto 0);
		output	: out unsigned (7 downto 0)
   );

  end component;
  end package;