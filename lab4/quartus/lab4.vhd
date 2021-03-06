library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.lab4_pkg.all; -- types and constants that we will use
                       -- look in lab4_pkg.vhd to see these defns
							  
----------------------------------------------------------------
--
--  This file is the starting point for Lab 4.  This design implements
--  a simple pong game, with a paddle at the bottom and one ball that 
--  bounces around the screen.  When downloaded to an FPGA board, 
--  SW(0) will control the paddle. KEY(3) will reset the game.  If the ball drops
--  below the bottom of the screen without hitting the paddle, the game
--  will reset.
--
--  This is written in a combined datapath/state machine style as
--  discussed in the second half of Slide Set 8.  It looks like a 
--  state machine, but the datapath operations that will be performed
--  in each state are described within the corresponding WHEN clause
--  of the state machine.  From this style, Quartus II will be able to
--  extract the state machine from the design.
--
--  In Lab 4, you will modify this file as described in the handout.
--
--  This file makes extensive use of types and constants described in
--  lab4_pkg.vhd    Be sure to read and understand that file before
--  trying to understand this one.
-- 
------------------------------------------------------------------------

-- Entity part of the description.  Describes inputs and outputs

entity lab4 is
  port(CLOCK_50            : in  std_logic;  -- Clock pin
       KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
       SW                  : in  std_logic_vector(17 downto 0);  -- slider switches
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab4;

-- Architecture part of the description

architecture rtl of lab4 is

  -- These are signals that will be connected to the VGA adapater.
  -- The VGA adapater was described in the Lab 3 handout.
  
  signal resetn : std_logic;
  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  signal draw  : point;
  
   -- determines the player turn ( by colour)

  -- Be sure to see all the constants, types, etc. defined in lab4_pkg.vhd
  
begin

  -- include the VGA controller structurally.  The VGA controller 
  -- was decribed in Lab 3.  You probably know it in great detail now, but 
  -- if you have forgotten, please go back and review the description of the 
  -- VGA controller in Lab 3 before trying to do this lab.
  
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);

  -- the x and y lines of the VGA controller will be always
  -- driven by draw.x and draw.y.   The process below will update
  -- signals draw.x and draw.y.
  
  x <= std_logic_vector(draw.x(x'range));
  y <= std_logic_vector(draw.y(y'range));
 

  -- =============================================================================
  
  -- This is the main process.  As described above, it is written in a combined
  -- state machine / datapath style.  It looks like a state machine, but rather
  -- than simply driving control signals in each state, the description describes 
  -- the datapath operations that happen in each state.  From this Quartus II
  -- will figure out a suitable datapath for you.
  
  -- Notice that this is written as a pattern-3 process (sequential with an
  -- asynchronous reset)
  
  controller_state : process(CLOCK_50, KEY)	 
  
    -- This variable will contain the state of our state machine.  The 
	 -- draw_state_type was defined above as an enumerated type	 
    variable state : draw_state_type := START; 
	 
	 --decides the whos turn it iss
	 variable player_turn: std_logic_vector(2 downto 0);
	 
    -- This variable will store the x position of the paddle (left-most pixel of the paddle)
	 variable paddle_x : unsigned(draw.x'range);
	 -- player 2
	 variable paddle_x_2 : unsigned(draw.x'range);
	 
	 variable paddle_y: unsigned(draw.y'range);
	 variable paddle_y_2 : unsigned (draw.y'range);
	 
	 -- These variables will store the puck and the puck velocity.
	 -- In this implementation, the puck velocity has two components: an x component
	 -- and a y component.  Each component is always +1 or -1.
    variable puck :position;
	 variable puck_velocity : velocity;
	 
	 -- This will be used as a counter variable in the IDLE state
    variable clock_counter : natural := 0;	
	 -- when this reaches 160 (20 * 8 Hz) subtracts from the width of each paddle
	 variable timer_smaller, timer_smaller_2 : natural := 0;
	 variable smaller_paddles, smaller_paddles_2 : natural := 0;

 begin
 
    -- first see if the reset button has been pressed.  If so, we need to
	 -- reset to state INIT
	 
    if KEY(3) = '0' then
           draw <= (x => to_unsigned(0, draw.x'length),
                 y => to_unsigned(0, draw.y'length));			  
           paddle_x := to_unsigned(PADDLE_X_START, paddle_x'length);
			  paddle_x_2 := to_unsigned(PADDLE_X_START, paddle_x'length);
			  
			  puck.x := to_unsigned(FACEOFF_X, puck.x'length );
			  puck.y := to_unsigned(FACEOFF_Y, puck.y'length );
			  puck_velocity.x := to_signed(248, puck_velocity.x'length );
			  puck_velocity.y := to_signed(-40, puck_velocity.y'length );			  
           colour <= BLACK;
			  plot <= '1';
			  player_turn := GREEN;
			  smaller_paddles := 0;

	     state := INIT;
	
    -- Otherwise, see if we are here because of a rising clock edge.  This follows
	 -- the standard pattern for a type-3 process we saw in the lecture slides.
	 
    elsif rising_edge(CLOCK_50) then

      case state is
		
		  -- ============================================================
		  -- The INIT state sets the variables to their default values
		  -- ============================================================
		  
		  when INIT =>
 
           draw <= (x => to_unsigned(0, draw.x'length),
                 y => to_unsigned(0, draw.y'length));			  
           paddle_x := to_unsigned(PADDLE_X_START, paddle_x'length);
			  paddle_x_2 := to_unsigned(PADDLE_X_START, paddle_x'length);
			  
			  paddle_y := to_unsigned(PADDLE_ROW-1, paddle_y'length);
			  paddle_y_2 := to_unsigned(PadDLE_ROW_2, paddle_y_2'length);
			  
			  puck.x(15 downto 8) := to_unsigned(FACEOFF_X, draw.x'length );
			  puck.y(15 downto 8) := to_unsigned(FACEOFF_Y, draw.y'length );
			  
			  puck.x(7 downto 0) := to_unsigned(0, draw.x'length );
			  puck.y(7 downto 0) := to_unsigned(0, draw.y'length );
			  
			  puck_velocity.x(15 downto 8) := to_signed(0, draw.x'length );
			  puck_velocity.y(15 downto 0) := to_signed(-40, puck_velocity.y'length );

			  puck_velocity.x(7 downto 0) := to_signed(248, draw.x'length );
			  --puck_velocity.y(7 downto 0) := to_signed(40, draw.y'length );	
			  player_turn := GREEN;	
           colour <= BLACK;
			  plot <= '1';
			  state := START;  -- next state is START
			  smaller_paddles := 0;
			  smaller_paddles_2 := 0;	 
			  timer_smaller := 0;
			  timer_smaller_2 := 0;
				
		  -- ============================================================
        -- the START state is used to clear the screen.  We will spend many cycles
		  -- in this state, because only one pixel can be updated each cycle.  The  
		  -- counters in draw.x and draw.y will be used to keep track of which pixel 
		  -- we are erasing.  
		  -- ============================================================
		  
        when START =>	
		  
		    -- See if we are done erasing the screen		    
          if draw.x = SCREEN_WIDTH-1 then
            if draw.y = SCREEN_HEIGHT-1 then
				
				  -- We are done erasing the screen.  Set the next state 
				  -- to DRAW_TOP_ENTER

              state := DRAW_TOP_ENTER;	
		  
            else
				
				  -- In this cycle we will be erasing a pixel.  Update 
				  -- draw.y so that next time it will erase the next pixel
				  
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
   			  draw.x <= to_unsigned(0, draw.x'length);				  
            end if;
          else	
	
            -- Update draw.x so next time it will erase the next pixel    
			  	
            draw.x <= draw.x + to_unsigned(1, draw.x'length);

          end if;

		  -- ============================================================
        -- The DRAW_TOP_ENTER state draws the first pixel of the bar on
		  -- the top of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_TOP_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_TOP_ENTER =>				
			     draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
				  draw.y <= to_unsigned(TOP_LINE, draw.y'length);
				  colour <= WHITE;
				  state := DRAW_TOP_LOOP;
			  
		  -- ============================================================
        -- The DRAW_TOP_LOOP state is used to draw the rest of the bar on 
		  -- the top of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
        when DRAW_TOP_LOOP =>	
		  
           -- See if we have been in this state long enough to have completed the line
    		  if draw.x = RIGHT_LINE then
			     -- if so, the next state is DRAW_RIGHT_ENTER			  
              state := DRAW_RIGHT_ENTER; -- next state is DRAW_RIGHT
            else
				
				  -- Otherwise, update draw.x to point to the next pixel
              draw.y <= to_unsigned(TOP_LINE, draw.y'length);
              draw.x <= draw.x + to_unsigned(1, draw.x'length);
				  
				  -- Do not change the state, since we want to come back to this state
				  -- the next time we come through this process (at the next rising clock
				  -- edge) to finish drawing the line
				  
            end if;

		  -- ============================================================
        -- The DRAW_RIGHT_ENTER state draws the first pixel of the bar on
		  -- the right-side of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_RIGHT_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_RIGHT_ENTER =>				
			  draw.y <= to_unsigned(TOP_LINE, draw.x'length);
			  draw.x <= to_unsigned(RIGHT_LINE, draw.x'length);	
		     state := DRAW_RIGHT_LOOP;
   		  
		  -- ============================================================
        -- The DRAW_RIGHT_LOOP state is used to draw the rest of the bar on 
		  -- the right side of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
		  when DRAW_RIGHT_LOOP =>	

		  -- See if we have been in this state long enough to have completed the line
	   	  if draw.y = SCREEN_HEIGHT-1 then
		  
			     -- We are done, so the next state is DRAW_LEFT_ENTER	  
	 
              state := DRAW_LEFT_ENTER;	-- next state is DRAW_LEFT
            else

				  -- Otherwise, update draw.y to point to the next pixel				
              draw.x <= to_unsigned(RIGHT_LINE,draw.x'length);
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
            end if;	

		  -- ============================================================
        -- The DRAW_LEFT_ENTER state draws the first pixel of the bar on
		  -- the left-side of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_LEFT_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_LEFT_ENTER =>				
			  draw.y <= to_unsigned(TOP_LINE, draw.x'length);
			  draw.x <= to_unsigned(LEFT_LINE, draw.x'length);	
		     state := DRAW_LEFT_LOOP;
   		  
		  -- ============================================================
        -- The DRAW_LEFT_LOOP state is used to draw the rest of the bar on 
		  -- the left side of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
		  when DRAW_LEFT_LOOP =>

		  -- See if we have been in this state long enough to have completed the line		  
          if draw.y = SCREEN_HEIGHT-1 then

			     -- We are done, so get things set up for the IDLE state, which 
				  -- comes next.  
				  
              state := IDLE;  -- next state is IDLE
				  clock_counter := 0;  -- initialize counter we will use in IDLE  
				  
            else
				
				  -- Otherwise, update draw.y to point to the next pixel					
              draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
            end if;	
				  
		  
		  -- ============================================================
        -- The IDLE state is basically a delay state.  If we didn't have this,
		  -- we'd be updating the puck location and paddle far too quickly for the
		  -- the user.  So, this state delays for 1/8 of a second.  Once the delay is
		  -- done, we can go to state ERASE_PADDLE.  Note that we do not try to
		  -- delay using any sort of wait statement: that won't work (not synthesziable).  
		  -- We have to build a counter to count a certain number of clock cycles.
		  -- ============================================================
		  
        when IDLE =>  
		  
		    -- See if we are still counting.  LOOP_SPEED indicates the maximum 
			 -- value of the counter
			 
			 plot <= '0';  -- nothing to draw while we are in this state
			 
          if clock_counter < LOOP_SPEED then
			    clock_counter := clock_counter + 1;
          else 
			 
			     -- otherwise, we are done counting.  So get ready for the 
				  -- next state which is ERASE_PADDLE_ENTER
				  
              clock_counter := 0;
              state := ERASE_PADDLE_ENTER;  -- next state
				  
	
				  
	  
			 end if;

			 
			
		  when ERASE_PADDLE_ENTER =>		  
              draw.y <= paddle_y;
		     	  draw.x <= paddle_x;	
              colour <= BLACK;
              plot <= '1';			
              state := ERASE_PADDLE_LOOP;		
				 
		  when ERASE_PADDLE_LOOP =>
		  
		      -- See if we are done erasing the paddle (done with this state)
            if draw.x = paddle_x+PADDLE_WIDTH - smaller_paddles then			
				
				  -- If so, the next state is DRAW_PADDLE_ENTER. 
				  
              state := DRAW_PADDLE_ENTER;  -- next state is DRAW_PADDLE 
				  if (timer_smaller >159) then
						if (smaller_paddles < 5) then
							smaller_paddles := smaller_paddles +1;
						end if;
						timer_smaller := 0;
					else 
						timer_smaller := timer_smaller +1;
					end if;
				 
				 
            else

				  -- we are not done erasing the paddle.  Erase the pixel and update
				  -- draw.x by increasing it by 1
   		     draw.y <= paddle_y;
              draw.x <= draw.x + to_unsigned(1, draw.x'length);
				  
				  -- state stays the same, since we want to come back to this state
				  -- next time through the process (next rising clock edge) until 
				  -- the paddle has been erased
				  
            end if; 
-----------------------------------------------------------------------------------------------------				
		  when ERASE_PADDLE_ENTER_2 =>		  
              draw.y <= paddle_y_2;
		     	  draw.x <= paddle_x_2;	
              colour <= BLACK;
              plot <= '1';			
              state := ERASE_PADDLE_LOOP_2;		
				 
		  when ERASE_PADDLE_LOOP_2 =>
		  
		      -- See if we are done erasing the paddle (done with this state)
            if draw.x = paddle_x_2+PADDLE_WIDTH - smaller_paddles_2 then			
				
				  -- If so, the next state is DRAW_PADDLE_ENTER. 
				  
              state := DRAW_PADDLE_ENTER_2;  -- next state is DRAW_PADDLE 
					if (timer_smaller_2 >159) then
						if (smaller_paddles_2 < 5) then
							smaller_paddles_2 := smaller_paddles_2 +1;
						end if;
						timer_smaller_2 := 0;
					else 
						timer_smaller_2 := timer_smaller_2 +1;
					end if;
					
            else

				  -- we are not done erasing the paddle.  Erase the pixel and update
				  -- draw.x by increasing it by 1
   		     draw.y <= paddle_y_2;
              draw.x <= draw.x + to_unsigned(1, draw.x'length);
				  
				  -- state stays the same, since we want to come back to this state
				  -- next time through the process (next rising clock edge) until 
				  -- the paddle has been erased
				  
            end if;
				
-----------------		-----------------		-----------------		-----------------		-----------------				
				when DRAW_PADDLE_ENTER =>
		  
				  -- We need to figure out the x lcoation of the paddle before the 
				  -- start of DRAW_PADDLE_LOOP.  The x location does not change, unless
				  -- the user has pressed one of the buttons.
				  
				  if (SW(0) = '1') then 
				  
				     -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
					  
				     
						if paddle_x < to_unsigned(RIGHT_LINE - PADDLE_WIDTH - 1 + smaller_paddles, paddle_x'length) then 
							
							if paddle_x >= to_unsigned(RIGHT_LINE - PADDLE_WIDTH - 2 + smaller_paddles, paddle_x'length) then
     					   -- add 2 to the paddle position
								paddle_x := paddle_x + to_unsigned(1, paddle_x'length) ;
							else
								paddle_x := paddle_x + to_unsigned(2, paddle_x'length) ;
							end if;
					  end if;
				     -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
					  
				  else
				  
				     -- If the user has pressed the left button check to make sure we
					  -- are not already at the leftmost position of the screen
				  
				     if paddle_x > to_unsigned(LEFT_LINE + 1, paddle_x'length) then 	
							if paddle_x <= to_unsigned(LEFT_LINE +2, paddle_x'length) then 	
								paddle_x := paddle_x - to_unsigned(1,paddle_x'length);
							else
								-- subtract 2 from the paddle position 
								paddle_x := paddle_x - to_unsigned(2, paddle_x'length) ;	
							end if;
					  end if;
				  end if;

              -- In this state, draw the first element of the paddle	
				  
				  if (SW(1) = '1') then
				  
						if paddle_y > to_unsigned(TOP_LINE +1, paddle_y'length) then
							if (paddle_y > paddle_y_2 -1) or (paddle_y < paddle_y_2 +1) then
								paddle_y := paddle_y -1;
							end if;
						end if;
						
				   else
						
						if paddle_y < to_unsigned(PADDLE_ROW-1, paddle_y'length) then
							if (paddle_y < paddle_y_2 -1) or (paddle_y > paddle_y_2 +1) then
								paddle_y := paddle_y +1;
							end if;
						end if;
					end if;
						
				  
				  
				  
				  
   		     draw.y <= paddle_y;				  
				  draw.x <= paddle_x;  -- get ready for next state			  
              colour <= GREEN; -- when we draw the paddle, the colour will be GREEN		  
		        state := DRAW_PADDLE_LOOP;
				  
				  
			when DRAW_PADDLE_LOOP =>
		  
		      -- See if we are done drawing the paddle

            if draw.x = paddle_x+PADDLE_WIDTH - smaller_paddles then
				
				  -- If we are done drawing the paddle, set up for the next state
				  
              plot  <= '0';  
              state := ERASE_PADDLE_ENTER_2;	-- next state is ERASE_PUCK
				else		
				
				  -- Otherwise, update the x counter to the next location in the paddle 
              draw.y <= paddle_y;
              draw.x <= draw.x + to_unsigned(1, draw.x'length);

				  -- state stays the same so we come back to this state until we
				  -- are done drawing the paddle

				  end if;
----------------------------------------------------------------------------------------------------			 
when DRAW_PADDLE_ENTER_2 =>
		  
				  -- We need to figure out the x lcoation of the paddle before the 
				  -- start of DRAW_PADDLE_LOOP.  The x location does not change, unless
				  -- the user has pressed one of the buttons.
				  
				  if (SW(16) = '1') then 
				  
				     -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
					  
				     if paddle_x_2 < to_unsigned(RIGHT_LINE - PADDLE_WIDTH - 1+ smaller_paddles_2, paddle_x'length) then 
							if paddle_x_2 >= to_unsigned(RIGHT_LINE - PADDLE_WIDTH - 2+ smaller_paddles_2, paddle_x'length) then
     					   -- add 2 to the paddle position
								paddle_x_2 := paddle_x_2 + to_unsigned(1, paddle_x'length) ;
							else
								paddle_x_2 := paddle_x_2 + to_unsigned(2, paddle_x'length) ;
							end if;
					  end if;
				     -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
					  
				  else
				  
				     -- If the user has pressed the left button check to make sure we
					  -- are not already at the leftmost position of the screen
				  
				     if paddle_x_2 > to_unsigned(LEFT_LINE + 1, paddle_x'length) then 				 
							if paddle_x_2 <= to_unsigned(LEFT_LINE +2, paddle_x'length) then 
								-- subtract 2 from the paddle position 
								paddle_x_2 := paddle_x_2 - to_unsigned(1, paddle_x'length) ;	
							else
								paddle_x_2 := paddle_x_2 - to_unsigned(2, paddle_x'length) ;
							end if;
					  end if;
				  end if;
				  
				  
				  if (SW(17) = '1') then
				  
						if paddle_y_2 > to_unsigned(TOP_LINE +1, paddle_y'length) then
							if (paddle_y_2 > paddle_y -1) or (paddle_y_2 < paddle_y +1) then
								paddle_y_2 := paddle_y_2 -1;
							end if;
						end if;
						
				   else
						
						if paddle_y_2 < to_unsigned(PADDLE_ROW-1, paddle_y'length) then
							if (paddle_y_2 < paddle_y -1) or (paddle_y_2 > paddle_y +1) then
								paddle_y_2 := paddle_y_2 +1;
							end if;
						end if;
					end if;

              -- In this state, draw the first element of the paddle	
				  
   		     draw.y <= paddle_y_2;				  
				  draw.x <= paddle_x_2;  -- get ready for next state			  
              colour <= RED; -- when we draw the paddle, the colour will be GREEN		  
		        state := DRAW_PADDLE_LOOP_2;
				  
				  
			when DRAW_PADDLE_LOOP_2 =>
		  
		      -- See if we are done drawing the paddle

            if draw.x = paddle_x_2+PADDLE_WIDTH- smaller_paddles_2 then
				
				  -- If we are done drawing the paddle, set up for the next state
				  
              plot  <= '0';  
              state := ERASE_PUCK;	-- next state is ERASE_PUCK
				else		
				
				  -- Otherwise, update the x counter to the next location in the paddle 
              draw.y <= paddle_y_2;
              draw.x <= draw.x + to_unsigned(1, draw.x'length);

				  -- state stays the same so we come back to this state until we
				  -- are done drawing the paddle

				  end if;			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
		  -- ============================================================
        -- The ERASE_PUCK state erases the puck from its old location   
		  -- At also calculates the new location of the puck. Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.
		  -- ============================================================
		  
        when ERASE_PUCK =>
				  colour <= BLACK;  -- erase by setting colour to black
              plot <= '1';
				 -- draw <= puck;  -- the x and y lines are driven by "puck" which 
				                   -- holds the location of the puck.
					
					draw.x <= puck.x(15 downto 8);
					draw.y <= puck.y(15 downto 8);
					
------------------------------------------------------------------------------------------------------------										 
				 	 
										 
				  state := DRAW_PUCK;  -- next state is DRAW_PUCK.

				  -- update the location of the puck 
				  puck.x := unsigned( signed(puck.x) + puck_velocity.x);
				  puck.y := unsigned( signed(puck.y) + puck_velocity.y);				  
				  
				  -- See if we have bounced off the top of the screen
				  if puck.y(15 downto 8) = TOP_LINE + 1 then
				     puck_velocity.y := 0-puck_velocity.y;
				  end if;

				  -- See if we have bounced off the right or left of the screen
				  if puck.x(15 downto 8) = LEFT_LINE + 1 or
				     puck.x(15 downto 8) = RIGHT_LINE - 1 then
				     puck_velocity.x := 0-puck_velocity.x;
				  end if;				  
				
				if puck.y(15 downto 8) > PadDLE_ROW then
					state := init;
				end if;
		
				
				if (player_turn = GREEN) then	
					if (puck.y(15 downto 8) = paddle_y_2-1)and puck_velocity.y > 0 then
						if puck.x(15 downto 8) >= paddle_x_2 and puck.x(15 downto 8) <= paddle_x_2 + PADDLE_WIDTH - smaller_paddles then
						
						state:= INIT;
						
						end if;
					end if;
					
					if puck.y(15 downto 8) = paddle_y - 1 and puck_velocity.y > 0 then
						  if puck.x(15 downto 8) >= paddle_x and puck.x(15 downto 8) <= paddle_x + PADDLE_WIDTH - smaller_paddles then
						  
							  -- we have bounced off the paddle
							  puck_velocity.y := 0-puck_velocity.y-5;
							  player_turn := RED;
						  
						  end if;	  
					end if;
					
				else 
					if (puck.y(15 downto 8) = paddle_y_2-1) and puck_velocity.y > 0 then
						if puck.x(15 downto 8) >= paddle_x_2 and puck.x(15 downto 8) <= paddle_x_2 + PADDLE_WIDTH - smaller_paddles   then
						
							puck_velocity.y := 0-puck_velocity.y-5;
							player_turn := GREEN;
						
						end if;
					end if;
					
					if puck.y(15 downto 8) = paddle_y - 1 and puck_velocity.y > 0 then
						  if puck.x(15 downto 8) >= paddle_x and puck.x(15 downto 8) <= paddle_x + PADDLE_WIDTH - smaller_paddles then
						  
							  state:= init;
						  
						  end if;	  
					end if;
				  
				end if;
				  
		  -- ============================================================
        -- The DRAW_PUCK draws the puck.  Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.					 
		  -- ============================================================
		  
        when DRAW_PUCK =>
				  if (player_turn = GREEN) then
						colour <= GREEN;
				  else 
						colour <= RED;
				  end if;
              plot <= '1';
---------------------------------------------------------------------------------------------------
					-- gravity update
				  puck_velocity.y := puck_velocity.y + 1;
		
				  draw.x <= puck.x(15 downto 8);
				  draw.y <= puck.y(15 downto 8);
				  
				  state := IDLE;	  -- next state is IDLE (which is the delay state)			  

 		  -- ============================================================
        -- We'll never get here, but good practice to include it anyway
		  -- ============================================================
		  
        when others =>
		    state := START;
			 
      end case;
	 end if;
   end process;
end RTL;


