library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_top is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3_top;

architecture rtl of lab3_top is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  signal x      : unsigned(7 downto 0);
  signal y      : unsigned(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;

begin

  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => std_logic_vector(x),
             y         => std_logic_vector(y),
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);

	process (CLOCK_50)
	begin
		
		if(falling_edge(CLOCK_50) & KEY(3)) then
			if (y > 120) then
				x <= x+1;
				y <= to_unsigned(0,y'length);
				colour <= std_logic_vector(to_unsigned((to_integer(x) mod integer(8)),colour'length));
			else
				y <= y+1;
				colour <= std_logic_vector(to_unsigned((to_integer(x) mod integer(8)),colour'length));
			end if;
		end if;
		
		if (KEY(3)) then
			y<= to_unsigned(0,y'length);
			x<= to_unsigned(0,x'length);
		end if;
	
	end process;

end RTL;


