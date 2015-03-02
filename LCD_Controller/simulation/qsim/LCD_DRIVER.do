onerror {quit -f}
vlib work
vlog -work work LCD_DRIVER.vo
vlog -work work LCD_DRIVER.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.LCD_Display_Controller_vlg_vec_tst
vcd file -direction LCD_DRIVER.msim.vcd
vcd add -internal LCD_Display_Controller_vlg_vec_tst/*
vcd add -internal LCD_Display_Controller_vlg_vec_tst/i1/*
add wave /*
run -all
