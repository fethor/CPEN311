library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity adder1710 is
	port(
		SW	: in std_logic_vector(17 downto 10);
		output	: out unsigned (7 downto 0)
	);
end entity;

architecture rtl of adder1710 is
begin
	output <= unsigned(SW(17 downto 10));
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package Adder1710_decl is
  component adder1710 is
  port(SW	: in std_logic_vector(9 downto 2);
		output	: out unsigned (7 downto 0)
   );

  end component;
  end package;