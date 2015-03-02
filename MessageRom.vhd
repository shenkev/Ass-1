LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all ;

-- 5 by 7 pixel ASCii character generator rom

entity MessageRom is
	Port (
	
		Address	: in std_logic_Vector(9 downto 0);		-- 10 bits at least 544 locations (17 strings of 32 chars each)
		DataOut  : out std_logic_vector(7 downto 0)		-- a character
	);
end ;


architecture bhvr of MessageRom is
	type CharRom5x7 is array ( 0 to 1023 ) of std_logic_vector(7 downto 0);
	constant MyRom : CharRom5x7 := 
						(
-- message strings 0 - 15 for displaying on LCD
-- Hex 80 or Hex C0 must be first character as it tells LCD to go to beginning of line 0 or line 1
-- then you can have upto 30 characters or text (remember LCD only displays 16 on a line)
-- then you MUST have a hex 00 byte at the end
-- do not delete ANY of these characters even if you do not use them, although you can replace the text
-- they are all needed.

								X"80",X"31",X"32",X"33",X"34",X"35",X"36",X"37",X"38",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"45",X"46",X"47",X"48",X"49",X"50",X"51",X"52",X"53",X"54",X"55",X"56",X"57",X"58",X"59",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"53",X"54",X"55",X"56",X"57",X"58",X"59",X"60",X"61",X"62",X"63",X"64",X"65",X"66",X"67",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"55",X"56",X"57",X"58",X"59",X"60",X"61",X"62",X"63",X"64",X"65",X"66",X"67",X"68",X"69",X"70",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"35",X"34",X"41",X"42",X"43",X"44",X"45",X"46",X"47",X"48",X"49",X"50",X"51",X"52",X"53",X"54",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"80",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00", X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",

								
-- final (17th) init string DO NOT CHANGE or DELETE - it contains characters to initialise the LCD display to use 2 line display, 8 bit data interface, cursor display on, display on and then clear display

								X"38",X"0e",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
								others => X"00"
						);
Begin
	process(Address)
		variable	index : integer range 0 to 1023 ;	
	begin
		index := to_integer(unsigned(Address)) ;
		DataOut <= MyRom(index);
	end process ;
END ;

