-------------------------------------------------------------------------------
-- FPU for 8 bit computers
-------------------------------------------------------------------------------
-- Engineer:	shurik-ua
--
--29.09.2015 - Initial board for development
--
-------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;  

entity u8_test_fpu is
	port (
	-- Clock (50MHz)
	CLK_50MHZ			: in std_logic;
	-- SRAM (CY7C1049DV33-10)
	SRAM_A				: out std_logic_vector(19 downto 0);
	SRAM_D				: inout std_logic_vector(7 downto 0);
	SRAM_WE_n			: out std_logic;
	-- SDRAM (MT48LC32M8A2-75)
	DRAM_A				: out std_logic_vector(12 downto 0);
	DRAM_D				: inout std_logic_vector(7 downto 0);
	DRAM_BA				: out std_logic_vector(1 downto 0);
	DRAM_CLK				: out std_logic;
	DRAM_WE_n			: out std_logic;
	DRAM_CAS_n			: out std_logic;
	DRAM_RAS_n			: out std_logic;
	-- RTC (PCF8583)
	RTC_INT_n			: in std_logic;
	RTC_SCL				: inout std_logic;
	RTC_SDA				: inout std_logic;
	-- FLASH (M25P40)
	DATA0					: in std_logic;
	NCSO					: out std_logic;
	DCLK					: out std_logic;
	ASDO					: out std_logic;
	-- Audio Codec (VS1053B)
	VS_XCS				: out std_logic;
	VS_XDCS				: out std_logic;
	VS_DREQ				: in std_logic;
	-- VGA	
	VGA_R					: out std_logic_vector(2 downto 0);
	VGA_G					: out std_logic_vector(2 downto 0);
	VGA_B					: out std_logic_vector(2 downto 0);
	VGA_VSYNC			: out std_logic;
	VGA_HSYNC			: out std_logic;
	-- External I/O
	RST_n					: in std_logic;
	GPI					: in std_logic;
	GPIO					: inout std_logic;
	-- PS/2 Keyboard
	PS2_KBCLK			: in std_logic;
	PS2_KBDAT			: in std_logic;		
	-- PS/2 Mouse	
	PS2_MSCLK			: in std_logic;
	PS2_MSDAT			: in std_logic;		
	-- USB-UART (FT232RL)
	TXD					: in std_logic;
	RXD					: out std_logic;
	CBUS4					: in std_logic;
	-- SD/MMC Card
	SD_CLK				: out std_logic;
	SD_DAT0				: in std_logic;
	SD_DAT1				: in std_logic;
	SD_DAT2				: in std_logic;
	SD_DAT3				: out std_logic;
	SD_CMD				: out std_logic;
	SD_PROT				: in std_logic
	);		
				
end u8_test_fpu;

architecture rtl of u8_test_fpu is

-- CPU
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_do			: std_logic_vector(7 downto 0);
signal cpu_di			: std_logic_vector(7 downto 0);
signal cpu_clk			: std_logic;
signal cpu_mreq_n		: std_logic;
signal cpu_iorq_n		: std_logic;
signal cpu_wr_n		: std_logic;
signal cpu_rd_n		: std_logic;
signal cpu_int			: std_logic;
signal cpu_m1_n		: std_logic;
signal cpu_inta		: std_logic;
signal cpu_reset		: std_logic;

signal res_cnt			: std_logic_vector(15 downto 0);
signal rom_data		: std_logic_vector(7 downto 0);
signal sel				: std_logic_vector(4 downto 0);
signal tacts_cnt		: std_logic_vector(23 downto 0);
signal tacts_cnt_f	: std_logic;

signal wr_video		: std_logic;
signal video_clk		: std_logic;
signal video_addr		: std_logic_vector(12 downto 0);
signal video_data		: std_logic_vector(7 downto 0);
signal reg_xxfe		: std_logic_vector(7 downto 0);
signal vid_scr			: std_logic;

signal kb_do_bus		: std_logic_vector(4 downto 0);

signal reg_7ffd		: std_logic_vector(7 downto 0);
signal mem_0x5b00		: std_logic_vector(7 downto 0);
	


begin

-- PLL
pll: entity work.altpll0
port map (
	inclk0		=> CLK_50MHZ,
	c0				=> cpu_clk,
	c1				=> video_clk
	);

-- Keyboard	
key: entity work.keyboard
port map(
	clk			=> cpu_clk,
	reset			=> cpu_reset,
	ps2_clk		=> PS2_KBCLK,
	ps2_data		=> PS2_KBDAT,
	a				=> cpu_addr(15 downto 8),
	keyb			=> kb_do_bus
	);	
	
--CPU
cpu: entity work.t80se
generic map (
	Mode			=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 1,	-- 0 => WR_n active in T3, 1 => WR_n active in T2
	IOWait		=> 1)	-- 0 => Single cycle I/O, 1 => Std I/O cycle
port map (
	RESET_n 		=> not cpu_reset,
	CLK_n   		=> cpu_clk,
	CLKEN   		=> '1',
	WAIT_n  		=> '1',
	INT_n   		=> not cpu_int,
	NMI_n   		=> '1',
	BUSRQ_n 		=> '1',
	M1_n    		=> cpu_m1_n,
	MREQ_n  		=> cpu_mreq_n,
	IORQ_n  		=> cpu_iorq_n,
	RD_n    		=> cpu_rd_n,
	WR_n    		=> cpu_wr_n,
	RFSH_n  		=> open,
	HALT_n  		=> open,
	BUSAK_n 		=> open,
	A       		=> cpu_addr,
	DI				=> cpu_di,
	DO      		=> cpu_do
    ); 

--ROM
rom: entity work.ram0
port map (
	data 			=> cpu_do,
	address		=> cpu_addr (13 downto 0),
	clock			=> cpu_clk,
	q				=> rom_data,
	wren			=> '0'
);	 

--VIDEO RAM
video_ram: entity work.video_ram0
port map (
	data			=> cpu_do,
	wraddress	=> vid_scr & cpu_addr(12 downto 0),
	wren			=> wr_video,
	wrclock		=> cpu_clk,
	q				=> video_data,
	rdaddress	=> reg_7ffd(3) & video_addr,
	rdclock		=> video_clk	
);

--VIDEO
video: entity work.spec_video_60
port map(
	CLK			=> video_clk,
	DI				=> video_data,
	BORDER		=> reg_xxfe (2 downto 0),
	ADDR			=> video_addr,
	INTA			=> cpu_inta,
	INT			=> cpu_int,
	R				=> VGA_R,
	G				=> VGA_G,
	B				=> VGA_B,
	HS				=> VGA_HSYNC,
	VS				=> VGA_VSYNC	
);

---------------
	cpu_di		<= rom_data when cpu_addr (15 downto 14) = "00" and cpu_mreq_n = '0' and cpu_rd_n = '0' else
						tacts_cnt(7 downto 0) when cpu_addr = X"5B00" and cpu_mreq_n = '0' and cpu_rd_n = '0' and reg_xxfe(7) = '1' else
						tacts_cnt(15 downto 8) when cpu_addr = X"5B01" and cpu_mreq_n = '0' and cpu_rd_n = '0' and reg_xxfe(7) = '1' else
						tacts_cnt(23 downto 16) when cpu_addr = X"5B02" and cpu_mreq_n = '0' and cpu_rd_n = '0' and reg_xxfe(7) = '1' else
						SRAM_D when cpu_addr (15 downto 14) /= "00" and cpu_mreq_n = '0' and cpu_rd_n = '0' else 
						'1' & GPI & '1' & kb_do_bus when cpu_addr(7 downto 0) = X"FE" and cpu_iorq_n = '0' and cpu_rd_n = '0' else 
						(others => '1');
	
	SRAM_WE_n	<= '0' when cpu_addr (15 downto 14) /= "00" and cpu_mreq_n = '0' and cpu_wr_n = '0' else '1';
	SRAM_A		<= '0' & sel & cpu_addr(13 downto 0);
	SRAM_D		<= cpu_do when cpu_mreq_n = '0' and cpu_wr_n = '0' else (others => 'Z');
	
	sel			<= reg_7ffd(7 downto 6) & reg_7ffd(2 downto 0) when cpu_addr(15 downto 14) = "11" else "00" & cpu_addr(14) & cpu_addr(15 downto 14);

	wr_video		<= '1' when cpu_addr (15 downto 14) = "01" and cpu_mreq_n = '0' and cpu_wr_n = '0' else '0';
	vid_scr		<= '1' when (sel = "00111") else '0';
	
-- PORTS
process (cpu_clk, cpu_reset, cpu_addr, cpu_iorq_n, cpu_wr_n)
begin
	if (cpu_reset = '1') then
		reg_7ffd <= (others => '0');
	elsif rising_edge (cpu_clk) then
		if (cpu_addr = X"7FFD" and cpu_iorq_n = '0' and cpu_wr_n = '0') then reg_7ffd <= cpu_do; end if;
		if (cpu_addr(7 downto 0) = X"FE" and cpu_iorq_n = '0' and cpu_wr_n = '0') then reg_xxfe <= cpu_do; end if;
	end if;
end process;

-- RESET & INT_ACK
process (cpu_clk, RST_N,cpu_iorq_n, cpu_mreq_n, cpu_m1_n)
begin
	if rising_edge(cpu_clk) then		
		cpu_inta <= not (cpu_iorq_n or cpu_m1_n);
		if (cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr = X"5B00") then mem_0x5b00 <= cpu_do; end if;
		if cpu_reset = '0' then
			cpu_reset <= not RST_N;			
		else
			res_cnt <= res_cnt + 1;
			if res_cnt = X"FFFF" then		
				res_cnt <= (others => '0');
				cpu_reset <= '0';
			end if;
		end if;
	end if;
end process; 

-- Tacts Counter
process (cpu_clk, cpu_reset)
begin
	if cpu_reset = '1' then
		tacts_cnt <= (others => '0');	
		tacts_cnt_f	<= '0';
	elsif rising_edge (cpu_clk) then
		if tacts_cnt_f = '0' then 
			if mem_0x5b00(0) = '1' then 
				tacts_cnt_f <= '1';
				tacts_cnt <= (others => '0');	
			end if;
		else
			if mem_0x5b00(0) = '1' then tacts_cnt <= tacts_cnt + 1;
			else tacts_cnt_f <= '0';
			end if;			
		end if;
	end if;
end process; 

end rtl;