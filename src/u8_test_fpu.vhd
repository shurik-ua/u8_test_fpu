-------------------------------------------------------------------------------
-- FPU
-------------------------------------------------------------------------------
-- Engineer:	shurik-ua
--
--
--
--
--
-------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;  

entity u8_test_fpu is
	port (
	-- Clock (50MHz)
	CLK_50MHZ		: in std_logic;
	-- SRAM (CY7C1049DV33-10)
	SRAM_A			: out std_logic_vector(19 downto 0);
	SRAM_D			: inout std_logic_vector(7 downto 0);
	SRAM_WE_n		: out std_logic;
	-- SDRAM (MT48LC32M8A2-75)
	DRAM_A			: out std_logic_vector(12 downto 0);
	DRAM_D			: inout std_logic_vector(7 downto 0);
	DRAM_BA			: out std_logic_vector(1 downto 0);
	DRAM_CLK			: out std_logic;
	DRAM_WE_n		: out std_logic;
	DRAM_CAS_n		: out std_logic;
	DRAM_RAS_n		: out std_logic;
	-- RTC (PCF8583)
	RTC_INT_n		: in std_logic;
	RTC_SCL			: inout std_logic;
	RTC_SDA			: inout std_logic;
	-- FLASH (M25P40)
	DATA0				: in std_logic;
	NCSO				: out std_logic;
	DCLK				: out std_logic;
	ASDO				: out std_logic;
	-- Audio Codec (VS1053B)
	VS_XCS			: out std_logic;
	VS_XDCS			: out std_logic;
	VS_DREQ			: in std_logic;
	-- VGA
	VGA_R				: out std_logic_vector(2 downto 0);
	VGA_G				: out std_logic_vector(2 downto 0);
	VGA_B				: out std_logic_vector(2 downto 0);
	VGA_VSYNC		: out std_logic;
	VGA_HSYNC		: out std_logic;
	-- External I/O
	RST_n				: in std_logic;
	GPI				: in std_logic;
	GPIO				: inout std_logic;
	-- PS/2 Keyboard
	PS2_KBCLK		: inout std_logic;
	PS2_KBDAT		: inout std_logic;		
	-- PS/2 Mouse
	PS2_MSCLK		: inout std_logic;
	PS2_MSDAT		: inout std_logic;		
	-- USB-UART (FT232RL)
	TXD				: in std_logic;
	RXD				: out std_logic;
	CBUS4				: in std_logic;
	-- SD/MMC Card
	SD_CLK			: out std_logic;
	SD_DAT0			: in std_logic;
	SD_DAT1			: in std_logic;
	SD_DAT2			: in std_logic;
	SD_DAT3			: out std_logic;
	SD_CMD			: out std_logic;
	SD_PROT			: in std_logic
	);		
				
end u8_test_fpu;

architecture rtl of u8_test_fpu is

begin



end rtl;