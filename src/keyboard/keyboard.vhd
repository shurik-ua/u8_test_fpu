-------------------------------------------------------------------[2013-04-24]
-- PS/2 scancode to Spectrum matrix conversion
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
port (
	CLK			: in std_logic;
	RESET		: in std_logic;
	-- PS/2 interface
	PS2_CLK		: in std_logic;
	PS2_DATA	: in std_logic;
	-- CPU address bus (row)
	A			: in std_logic_vector(7 downto 0);
	-- Column outputs to ULA
	KEYB		: out std_logic_vector(4 downto 0)
	);
end keyboard;

architecture rtl of keyboard is

-- PS/2 interface
component ps2_intf is
generic (filter_length : positive := 8);
port(
	CLK			: in std_logic;
	RESET		: in std_logic;
	-- PS/2 interface (could be bi-dir)
	PS2_CLK		: in std_logic;
	PS2_DATA	: in std_logic;
	-- Byte-wide data interface - only valid for one clock
	-- so must be latched externally if required
	DATA		: out std_logic_vector(7 downto 0);
	VALID		: out std_logic;
	ERROR		: out std_logic
	);
end component;

-- Interface to PS/2 block
signal keyb_data	: std_logic_vector(7 downto 0);
signal keyb_valid	: std_logic;

-- Internal signals
type key_matrix is array (7 downto 0) of std_logic_vector(4 downto 0);
signal keys		: key_matrix;
signal keys_out	: key_matrix;
signal release	: std_logic;
--signal extended	: std_logic;
begin	

ps2 : ps2_intf port map (
	CLK,
	RESET,
	PS2_CLK,
	PS2_DATA,
	keyb_data,
	keyb_valid,
 	open
	);

	-- Output addressed row to ULA
	keys_out(0) <= keys(0) when A(0) = '0' else "11111";
	keys_out(1) <= keys(1) when A(1) = '0' else "11111";
	keys_out(2) <= keys(2) when A(2) = '0' else "11111";
	keys_out(3) <= keys(3) when A(3) = '0' else "11111";
	keys_out(4) <= keys(4) when A(4) = '0' else "11111";
	keys_out(5) <= keys(5) when A(5) = '0' else "11111";
	keys_out(6) <= keys(6) when A(6) = '0' else "11111";
	keys_out(7) <= keys(7) when A(7) = '0' else "11111";
	
	KEYB <= keys_out(0) and keys_out(1) and
			keys_out(2) and keys_out(3) and
			keys_out(4) and keys_out(5) and
			keys_out(6) and keys_out(7);
	
	
--	KEYB <= (keys(0) when A(8) = '0' else "11111") and
--			  (keys(1) when A(9) = '0' else (others => '1')) and
--			  (keys(2) when A(10) = '0' else (others => '1')) and
--			  (keys(3) when A(11) = '0' else (others => '1')) and
--			  (keys(4) when A(12) = '0' else (others => '1')) and
--			  (keys(5) when A(13) = '0' else (others => '1')) and
--			  (keys(6) when A(14) = '0' else (others => '1')) and
--			  (keys(7) when A(15) = '0' else (others => '1'));

	process(RESET, CLK)
	begin
		if RESET = '1' then
			release <= '0';
--			extended <= '0';
			
			keys(0) <= (others => '1');
			keys(1) <= (others => '1');
			keys(2) <= (others => '1');
			keys(3) <= (others => '1');
			keys(4) <= (others => '1');
			keys(5) <= (others => '1');
			keys(6) <= (others => '1');
			keys(7) <= (others => '1');
		elsif rising_edge(CLK) then
			if keyb_valid = '1' then
				if keyb_data = X"e0" then
					-- Extended key code follows
--					extended <= '1';
				elsif keyb_data = X"f0" then
					-- Release code follows
					release <= '1';
				else
					-- Cancel extended/release flags for next time
					release <= '0';
--					extended <= '0';
				
					case keyb_data is					
					when X"12" => keys(0)(0) <= release; -- Left shift (CAPS SHIFT)
					when X"59" => keys(0)(0) <= release; -- Right shift (CAPS SHIFT)
					when X"1a" => keys(0)(1) <= release; -- Z
					when X"22" => keys(0)(2) <= release; -- X
					when X"21" => keys(0)(3) <= release; -- C
					when X"2a" => keys(0)(4) <= release; -- V
					
					when X"1c" => keys(1)(0) <= release; -- A
					when X"1b" => keys(1)(1) <= release; -- S
					when X"23" => keys(1)(2) <= release; -- D
					when X"2b" => keys(1)(3) <= release; -- F
					when X"34" => keys(1)(4) <= release; -- G
					
					when X"15" => keys(2)(0) <= release; -- Q
					when X"1d" => keys(2)(1) <= release; -- W
					when X"24" => keys(2)(2) <= release; -- E
					when X"2d" => keys(2)(3) <= release; -- R
					when X"2c" => keys(2)(4) <= release; -- T				
				
					when X"16" => keys(3)(0) <= release; -- 1
					when X"1e" => keys(3)(1) <= release; -- 2
					when X"26" => keys(3)(2) <= release; -- 3
					when X"25" => keys(3)(3) <= release; -- 4
					when X"2e" => keys(3)(4) <= release; -- 5			
					
					when X"45" => keys(4)(0) <= release; -- 0
					when X"46" => keys(4)(1) <= release; -- 9
					when X"3e" => keys(4)(2) <= release; -- 8
					when X"3d" => keys(4)(3) <= release; -- 7
					when X"36" => keys(4)(4) <= release; -- 6
					
					when X"4d" => keys(5)(0) <= release; -- P
					when X"44" => keys(5)(1) <= release; -- O
					when X"43" => keys(5)(2) <= release; -- I
					when X"3c" => keys(5)(3) <= release; -- U
					when X"35" => keys(5)(4) <= release; -- Y
					
					when X"5a" => keys(6)(0) <= release; -- ENTER
					when X"4b" => keys(6)(1) <= release; -- L
					when X"42" => keys(6)(2) <= release; -- K
					when X"3b" => keys(6)(3) <= release; -- J
					when X"33" => keys(6)(4) <= release; -- H
					
					when X"29" => keys(7)(0) <= release; -- SPACE
					when X"14" => keys(7)(1) <= release; -- CTRL (Symbol Shift)
					when X"3a" => keys(7)(2) <= release; -- M
					when X"31" => keys(7)(3) <= release; -- N
					when X"32" => keys(7)(4) <= release; -- B
					
					-- Cursor keys - these are actually extended (E0 xx), but
					-- the scancodes for the numeric keypad cursor keys are
					-- are the same but without the extension, so we'll accept
					-- the codes whether they are extended or not
					when X"6B" => 	keys(0)(0) <= release; -- Left (CAPS 5)
									keys(3)(4) <= release;
					when X"72" =>	keys(0)(0) <= release; -- Down (CAPS 6)
									keys(4)(4) <= release;
					when X"75" =>	keys(0)(0) <= release; -- Up (CAPS 7)
									keys(4)(3) <= release;
					when X"74" =>	keys(0)(0) <= release; -- Right (CAPS 8)
									keys(4)(2) <= release;
									
					-- Other special keys sent to the ULA as key combinations
					when X"66" =>	keys(0)(0) <= release; -- Backspace (CAPS 0)
									keys(4)(0) <= release;
					when X"58" =>	keys(0)(0) <= release; -- Caps lock (CAPS 2)
									keys(3)(1) <= release;
					when X"76" =>	keys(0)(0) <= release; -- Escape (CAPS SPACE)
									keys(7)(0) <= release;
					
					when others =>
						null;
					end case;
				end if;
			end if;
		end if;
	end process;

end architecture;
