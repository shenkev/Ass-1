library verilog;
use verilog.vl_types.all;
entity LCD_Display_Controller_vlg_sample_tst is
    port(
        CLK_50Mhz       : in     vl_logic;
        MessageNumber   : in     vl_logic_vector(3 downto 0);
        Reset_L         : in     vl_logic;
        WriteMessage_L  : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end LCD_Display_Controller_vlg_sample_tst;
