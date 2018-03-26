LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY lab5_top IS
	GENERIC (MAX_VOLUME : natural := 2**15;
				MAX_VOLUMEN	: integer := -2**15);
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY 	 															:IN STD_LOGIC_VECTOR (3 downto 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
        
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC);
END lab5_top;

ARCHITECTURE Behavior OF lab5_top IS

   -- CODEC Cores
	
	COMPONENT clock_generator
		PORT(	CLOCK_27														:IN STD_LOGIC;
		    	reset															:IN STD_LOGIC;
				AUD_XCK														:OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT(	CLOCK_50,reset												:IN STD_LOGIC;
		    	I2C_SDAT														:INOUT STD_LOGIC;
				I2C_SCLK														:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT audio_codec
		PORT(	CLOCK_50,reset,read_s,write_s							:IN STD_LOGIC;
				writedata_left, writedata_right						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK		:IN STD_LOGIC;
				read_ready, write_ready									:OUT STD_LOGIC;
				readdata_left, readdata_right							:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_DACDAT													:OUT STD_LOGIC);
	END COMPONENT;
	
	component noise IS 
   PORT ( CLOCK_50: in std_logic;
	       magnitude : in std_logic_vector(1 downto 0);
	       stream_in : in std_logic_vector(23 downto 0);
	       stream_out : out std_logic_vector(23 downto 0));
	end component;
	
	component fir8 IS 
   PORT ( CLOCK_50, valid: in std_logic;
          stream_in : in std_logic_vector(23 downto 0);
          stream_out : out std_logic_vector(23 downto 0));
	end component;
	

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedataleft_pure, writedataright_pure, writedata_left, writedata_right,
			 dataleft_noise, dataright_noise, dataleft_filtered, dataright_filtered,
			 datachoice_left, datachoice_right :STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset,sign, valid											:STD_LOGIC;
	signal signdecision													:unsigned(6 downto 0);
	signal queued_in :std_logic;
	signal state: std_LOGIC_VECTOR (2 downto 0);

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,
	AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);
	
	leftnoiser: noise port map (clock_50, SW(17 downto 16), writedataleft_pure, dataleft_noise);
	rightnoiser : noise port map(clock_50, SW(17 downto 16), writedataright_pure, dataright_noise);
	
	filterleft : fir8 port map (clock_50, valid, dataleft_noise, dataleft_filtered);
	filterright : fir8 port map (clock_50, valid, dataright_noise, dataright_filtered);
	
	writedata_left <= dataleft_filtered when SW(15 downto 14) = "10" else 
							dataleft_noise when SW(15 downto 14) = "01" else
							writedataleft_pure;
	
	writedata_right <= dataright_filtered when SW(15 downto 14) = "10" else 
							dataright_noise when SW(15 downto 14) = "01" else
							writedataright_pure;


	
	process (CLOCK_50) is
	variable delay : unsigned  (10 downto 0) := to_unsigned(0, 11);
	begin
	
	if (rising_edge(clock_50))then
		
		case state is 
		
		when "000" =>
			if (write_ready) = '1' then
			if queued_in = '0' then
				delay := delay +1;
				--50 000 000 / 48 000 ~ 1024
				if (delay = "00100000100") then
					delay := to_unsigned(0,delay'length);
					queued_in <= '1';
				end if;
			else 
				if (SW(6 downto 0) = "0000001") then
					state <= "001";
				elsif (SW(6 downto 1) = "000001") then
					state <= "010";
				elsif (SW(6 downto 2) = "00001") then
					state <= "011";
				elsif (SW(6 downto 3) = "0001") then
					state <= "100";
				elsif (SW(6 downto 4) = "001") then
					state <= "101";
				elsif (SW(6 downto 5) = "01") then
					state <= "110";
				elsif (SW(6) = '1') then
					state <= "111";
				else 
					state <= "000";
				end if;
			end if;
		else
			queued_in <= '1';
		
		end if;
			

		when "001" =>
		
			if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 91) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
			end if;
			
		when "010" =>

		if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 81) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
			end if;
		
	when "011" =>

		if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 72) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
			end if;
		
	when "100" =>

		if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 69) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
		end if;
		
	when "101" =>

		if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 61) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
		end if;
		
	when "110" =>
	if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 54) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
		end if;
		
	when "111" =>
		if (write_ready = '1') and (queued_in = '1') then
			write_s <= '1';
			valid <= '1';
			queued_in <= '0';
			if(Sign = '0') then	
				writedataleft_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_unsigned(MAX_VOLUME, writedataleft_pure'length));
			else 
				writedataleft_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
				writedataright_pure <= std_logic_vector(to_signed(MAX_VOLUMEN, writedataleft_pure'length));
			end if;
				
			signdecision <= signdecision +1;
			if (signdecision > 49) then
				signdecision <= to_unsigned(0, signdecision'length);
				sign <= not(sign);
			end if;
		else
			write_s <= '0';
			valid <= '0';
			state <= "000";
			
		end if;
	
	end case;
	

	
	if (reset = '1') then
			writedataleft_pure <= std_logic_vector(to_signed(0, writedataleft_pure'length));
			writedataright_pure <= std_logic_vector(to_signed(0, writedataleft_pure'length));
			queued_in <= '1';
		
	end if;
	
	end if;
	
	
	
	end process;


END Behavior;
