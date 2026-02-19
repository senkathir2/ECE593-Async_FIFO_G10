if [file exists "work" ] {vdel -all}

vlib work

#vlog ./rtl/hw_top.sv ./TRAD_TB/*.sv

vlog ./CLASS_TB/fifo_if.sv ./rtl/hw_top.sv ./CLASS_TB/fifo_pkg.sv ./CLASS_TB/tb_top.sv +cover=sbecft

vsim -coverage work.tb_top -voptargs="+acc"

add wave -r /*

run -all

coverage report -assert -binrhs -details -cvg -codeAll