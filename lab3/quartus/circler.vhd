library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity circler is
	generic (x : integer := 80;
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
end circler;

architecture statesof of circler is
 
 type octants is (oc1, oc2, oc3, oc4, oc5, oc6, oc7, oc8,next_set, finished);
 signal circle_machine : octants;
 signal decision : signed (15 downto 0):= to_signed(0,16);
 signal offset_x_hold, offset_y_hold : unsigned (7 downto 0);
 signal checked : std_logic;
 

 begin
 
 
 process (clk) 
 variable offset_x, offset_y : unsigned (7 downto 0);
 begin
	
	if (falling_edge(clk)) then
		if enable then
	
		case (circle_machine) is
			when (oc1) =>
				plot <= '1';
				done <= '0';
			  if (checked) then
				  offset_x := "00"&radius;
				  offset_y := to_unsigned(0,offset_y'length);
				  decision <= 1-to_signed(to_integer(offset_x),decision'length);
				else 
				  offset_x := offset_x_hold;
				  offset_y := offset_y_hold;
				end if;
				position_x <= "0"&(to_unsigned(x,7)+offset_x);
				position_y <= to_unsigned(y,7)+offset_y;
				
				offset_x_hold <= offset_x;
				offset_y_hold <= offset_y;
				circle_machine <= oc2;
			
			when (oc2) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)+offset_y);
				position_y <= to_unsigned(y,7)+offset_x;
				circle_machine <= oc3;
			
			when (oc3) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)-offset_x);
				position_y <= to_unsigned(y,7)+offset_y;
				circle_machine <= oc4;
			
			when (oc4) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)-offset_y);
				position_y <= to_unsigned(y,7)+offset_x;
				circle_machine <= oc5;
			
			when (oc5) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)-offset_x);
				position_y <= to_unsigned(y,7)-offset_y;
				circle_machine <= oc6;
			
			when (oc6) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)-offset_y);
				position_y <= to_unsigned(y,7)-offset_x;
				circle_machine <= oc7;
			
			when (oc7) =>
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				position_x <= "0"&(to_unsigned(x,7)+offset_x);
				position_y <= to_unsigned(y,7)-offset_y;
				circle_machine <= oc8;
	--sets up for the next cycle or stops the machine depending on the offsets		
			when (oc8) =>
			  checked <= '0';
				plot <='1';
				offset_x := offset_x_hold;
				offset_y := offset_y_hold;
				
				
				if (offset_y > offset_x) then
					circle_machine <= finished;
					plot <= '0';
				else
				  
					offset_y := offset_y +1;
					if (decision < 1) then
						decision <= decision + 2* to_signed(to_integer(offset_y),8) +1;
						circle_machine <= oc1;
					else 
						offset_x := offset_x - 1;
						decision <= decision + 2*to_signed(to_integer(offset_y),offset_y'length)-2*to_signed(to_integer(offset_x),offset_x'length)+1;
						
						circle_machine <= oc1;
					end if;
				end if;
				
				position_x <= "0"&(to_unsigned(x,7)+offset_y);
				position_y <= to_unsigned(y,7)-offset_x;
				offset_x_hold <= offset_x;
				offset_y_hold <= offset_y;
	--when the machine is in the done state it can not restart until enable is low and will not print		
			when others =>
				plot <= '0';
				done <= '1';
				
			end case;
			end if;
		end if;
--resets the machine at the end of every cycle	
		if (not enable) then
			done <= '0';
			circle_machine <= oc1;
			checked <= '1';
		end if;
	
	end process;

END;
				