-------------------------------------------------------------------[20.07.2013]
-- spec_video_60
-------------------------------------------------------------------------------
-- Engineer: 	shurik-ua, MVV
-- Description: 
--	spectrum video mode 60 Hz
--	horis_sync = 30000 kHz
--  vert_sync   = 60 Hz
--
-- Versions:
-- V1.00	14.07.2013:
--		Initial release.
-- V1.01 16.07.2013:
--		Добавлены сигналы INT, INTA
-- V1.02 20.07.2013:
--      небольшие оптимизации
-- V1.03 07.09.2013:
--      final release
-------------------------------------------------------------------------------


library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity spec_video_60 is
	port (
		CLK			: in std_logic;		--12 MHz
		DI			: in std_logic_vector(7 downto 0);
		BORDER		: in std_logic_vector(2 downto 0);
		ADDR		: out std_logic_vector(12 downto 0);
		INTA		: in std_logic;
		INT			: out std_logic;
		R			: out std_logic_vector(2 downto 0);
		G			: out std_logic_vector(2 downto 0);
		B			: out std_logic_vector(2 downto 0);
		HS			: out std_logic;
		VS			: out std_logic
	);
end	entity spec_video_60;

architecture rtl of spec_video_60 is


signal h_cnt		: std_logic_vector (8 downto 0) :=(others => '0');
signal v_cnt		: std_logic_vector (8 downto 0) :=(others => '0');
signal out_data		: std_logic_vector(5 downto 0) :=(others => '0');
signal blank		: std_logic;
signal pixel		: std_logic;
signal pixel_out	: std_logic;
signal pixel_data	: std_logic_vector(7 downto 0);
signal attr_data	: std_logic_vector(7 downto 0);
signal tmp			: std_logic_vector(7 downto 0);
signal bord			: std_logic;
signal flash		: std_logic_vector(4 downto 0);

begin

process (CLK)
begin
	if rising_edge(CLK) then 
		if h_cnt = 399 then 
			h_cnt <= (others => '0');
			if v_cnt = 499 then
				v_cnt <= (others => '0');
				flash <= flash +1;
			else
				v_cnt <= v_cnt + 1;
			end if;
		else
			h_cnt <= h_cnt + 1;
		end if;
	end if;
end process;	

process (CLK,h_cnt(2 downto 0))	
begin
	if rising_edge(CLK) then 
		case h_cnt (2 downto 0) is
			when "011" => 			
				ADDR <= v_cnt(8 downto 7) & v_cnt(3 downto 1) & v_cnt(6 downto 4) & h_cnt(7 downto 3);
			when "101" => 				
				tmp <= DI;				
				ADDR <= "110" & v_cnt(8 downto 4) & h_cnt(7 downto 3);					
			when "111" => 
				pixel_data <= tmp;
				attr_data <= DI;				
			when others =>
		end case;
	end if;
end process;

process (h_cnt(2 downto 0),pixel_data)	
begin
	case h_cnt (2 downto 0) is
		when "000" => 
			pixel <= pixel_data(7);				
		when "001" => 
			pixel <= pixel_data(6);											
		when "010" => 				
			pixel <= pixel_data(5);							
		when "011" => 
			pixel <= pixel_data(4);				
		when "100" => 
			pixel <= pixel_data(3);				
		when "101" => 
			pixel <= pixel_data(2);
		when "110" => 
			pixel <= pixel_data(1);
		when others => 
			pixel <= pixel_data(0);
	end case;
end process;

process (CLK,blank,pixel_out,attr_data)	
begin
	if rising_edge(CLK) then 
		if blank = '1' then out_data <= (others => '0');
		elsif bord = '1' then out_data <= BORDER(1) & '0' & BORDER(2) & '0' & BORDER(0) & '0';
		elsif pixel_out = '0' then out_data <= attr_data(4) & (attr_data(4) and attr_data(6)) & attr_data(5) & (attr_data(5) and attr_data(6)) & attr_data(3) & (attr_data(3) and attr_data(6));
		else out_data <=  attr_data(1) & (attr_data(1) and attr_data(6)) & attr_data(2) & (attr_data(2) and attr_data(6)) & attr_data(0) & (attr_data(0) and attr_data(6));
		end if;		
	end if;
end process;

-- INT
process (CLK, INTA, v_cnt, h_cnt)
begin
	if INTA = '1' then
		INT <= '0';
	elsif CLK'event and CLK = '1' then
		if v_cnt = 436 and h_cnt = 0 then 
			INT <= '1';
		end if;
	end if;
end process;

pixel_out <= pixel when attr_data(7) = '0' else pixel xor flash(4);

blank <= '1' when ((h_cnt > 315) and (h_cnt <370)) or ((v_cnt > 433 ) and (v_cnt < 450)) else '0';
bord <='1' when (h_cnt > 263) or (h_cnt <8) or (v_cnt > 383 )  else '0';

HS <= '1' when (h_cnt > 313) and (h_cnt < 358) else '0';
VS <= '1' when (v_cnt > 429) and (v_cnt < 432) else '0';

R <= out_data (5 downto 4) & 'Z';
G <= out_data (3 downto 2) & 'Z';
B <= out_data (1 downto 0) & 'Z';

end	architecture rtl;