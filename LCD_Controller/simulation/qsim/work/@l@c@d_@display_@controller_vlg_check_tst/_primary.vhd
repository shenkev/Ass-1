library verilog;
use verilog.vl_types.all;
entity LCD_Display_Controller_vlg_check_tst is
    port(
        DB              : in     vl_logic_vector(7 downto 0);
        DriverReady     : in     vl_logic;
        E               : in     vl_logic;
        LCD_BLON_DE2    : in     vl_logic;
        LCD_ON_DE2      : in     vl_logic;
        Ready_H         : in     vl_logic;
        RomOut          : in     vl_logic_vector(7 downto 0);
        RS              : in     vl_logic;
        RW              : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end LCD_Display_Controller_vlg_check_tst;
