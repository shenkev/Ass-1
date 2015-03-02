library verilog;
use verilog.vl_types.all;
entity LCD_Display_Controller is
    port(
        LCD_ON_DE2      : out    vl_logic;
        Reset_L         : in     vl_logic;
        CLK_50Mhz       : in     vl_logic;
        WriteMessage_L  : in     vl_logic;
        MessageNumber   : in     vl_logic_vector(3 downto 0);
        LCD_BLON_DE2    : out    vl_logic;
        E               : out    vl_logic;
        RW              : out    vl_logic;
        RS              : out    vl_logic;
        Ready_H         : out    vl_logic;
        DriverReady     : out    vl_logic;
        DB              : out    vl_logic_vector(7 downto 0);
        RomOut          : out    vl_logic_vector(7 downto 0)
    );
end LCD_Display_Controller;
