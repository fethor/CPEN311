--------------------------------------------------------
--
--  This is the skeleton file for Lab 1 Phase 3.  You should
--  start with this file when you describe your state machine.  
--  
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------
--
--  This is the entity part of the top level file for Phase 3.
--  The entity part declares the inputs and outputs of the
--  module as well as their types.  For now, a signal of
--  “std_logic” type can take on the value ‘0’ or ‘1’ (it
--  can actually do more than this).  A signal of type
--  std_logic_vector can be thought of as an array of 
--  std_logic, and is used to describe a bus (a parallel 
--  collection of wires).
--
--  Note: you don't have to change the entity part.
--  
----------------------------------------------------------

entity Task3 is
   port (clk : in std_logic;  -- clock input to state machine
         resetb : in std_logic;  -- active-low reset input
         skip : in std_logic;     -- skip input
         hex0 : out std_logic_vector(6 downto 0)  -- output of state machine
            -- Note that in the above, hex0 is a 7-bit wide bus
            -- indexed using indices 6, 5, 4 ... down to 0.  The
            -- most-significant bit is hex(6) and the least significant
            -- bit is hex(0)
   );
end Task3;

----------------------------------------------------------------
--
-- The following is the architecture part of the state machine.  It 
-- describes the behaviour of the state machine using synthesizable
-- VHDL.  
--
----------------------------------------------------------------- 

architecture behavioural of Task3 is

-- Write your code here.

end behavioural;
