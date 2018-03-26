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
  
	component fullcircler is
		generic (x : integer := 60;
				y : integer := 60);
		port(clk : in std_logic;
			 enable: in std_logic;
			 reset : in std_logic;
			 radius: in unsigned (5 downto 0);
			 position_x: out unsigned (8 downto 0);
			 position_y: out unsigned (7 downto 0);
			 plot: out std_logic;
			 done: out std_logic
		);
	end component;
  
  

  signal x , clear_x     : unsigned(7 downto 0);
  signal y , clear_y     : unsigned(6 downto 0);
  signal colour, clear_colour, circle_colour : std_logic_vector(2 downto 0);
  signal plot, clear_plot, circle_plot   : std_logic;
  
  signal position_x : unsigned (8 downto 0);
  signal position_y : unsigned (7 downto 0);
  signal radius	  : unsigned (5 downto 0);
  signal circle_enable, cleared, done : std_logic;
  
  type states is (cir1, cir2, cir3, cir4, cir5, cir6, cir7, cir8,waiting);
  signal controller : states;

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
				 
	circle: fullcircler port map(clk => cloCK_50, enable => circle_enable, reset => key(3), radius => radius,
									position_x => position_x, position_y => position_y, plot => circle_plot, done => done);
									
x <= position_x(7 downto 0) when (circle_enable) else clear_x;
y <= position_y(6 downto 0) when (circle_enable) else clear_y;

colour <= circle_colour when (circle_enable) else clear_colour;
plot <= circle_plot when (circle_enable) else clear_plot;


									
									
									
process (CLOCK_50, KEY(3))
	begin
		 if(falling_edge(CLOCK_50)) then
			if not(cleared) then
				if (clear_y > 120) then
					clear_plot <= '1';
					clear_x <= clear_x+1;
					clear_y <= to_unsigned(0,y'length);
					clear_colour <= "000";
					if (clear_x > 159) then
						cleared <= '1';
					end if;
				else
					clear_plot <= '1';
					clear_y <= clear_y+1;
					clear_colour <= "000";
				end if;
			/*
			else 
				circle_enable <= '1';
				radius <= to_unsigned(30,radius'length);
				circle_colour <= "111";
			*/
			
			else	
-- the controller to handle the circle states
				case controller is 
					when cir1 =>
					  circle_enable <= '1';
						radius <= to_unsigned(30,radius'length);
						circle_colour <= "000";
						if (done) then
							circle_enable <= '0';
							controller <= cir2;
						end if;
						
					when cir2 =>
						circle_enable <= '1';
						radius <= to_unsigned(28,radius'length);
						circle_colour <= "001";
						if (done) then
							circle_enable <= '0';
							controller <= cir3;
					end if;
					
					when cir3 =>
						circle_enable <= '1';
						radius <= to_unsigned(26,radius'length);
						circle_colour <= "011";
						if (done) then
							circle_enable <= '0';
							controller <= cir4;
					end if;	
					
					when cir4 =>
						circle_enable <= '1';
						radius <= to_unsigned(24,radius'length);
						circle_colour <= "010";
						if (done) then
							circle_enable <= '0';
							controller <= cir5;
					end if;	
					
					when cir5 =>
						circle_enable <= '1';
						radius <= to_unsigned(22,radius'length);
						circle_colour <= "110";
						if (done) then
							circle_enable <= '0';
							controller <= cir6;
					end if;	
					
					when cir6 =>
						circle_enable <= '1';
						radius <= to_unsigned(20,radius'length);
						circle_colour <= "111";
						if (done) then
							circle_enable <= '0';
							controller <= cir7;
					end if;	
					
					when cir7 =>
						circle_enable <= '1';
						radius <= to_unsigned(18,radius'length);
						circle_colour <= "101";
						if (done) then
							circle_enable <= '0';
							controller <= cir8;
					end if;		
					
					when cir8 =>
						circle_enable <= '1';
						radius <= to_unsigned(16,radius'length);
						circle_colour <= "100";
						if (done) then
							circle_enable <= '0';
							controller <= waiting;
					end if;						
					
					when others =>  
						circle_enable <= '0';
			
				end case;
			
			
			
			end if;
		end if;
			
		
		
		if (KEY(3)) then
			controller <= cir1;
			clear_plot <= '0';
			cleared <= '0';
			circle_enable <= '0';
			clear_y<= to_unsigned(0,y'length);
			clear_x<= to_unsigned(0,x'length);
		end if;
	
end process;



end RTL;


