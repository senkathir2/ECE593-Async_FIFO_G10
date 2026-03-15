if [file exists "work" ] {vdel -all}

vlib work

#vlog ./rtl/hw_top.sv ./TRAD_TB/*.sv

vlog ./rtl/hw_top.sv +cover=sbecft

vlog ./UVM_TB/clkgen.sv

vlog ./UVM_TB/fifo_if.sv ./UVM_TB/fifo_pkg.sv ./UVM_TB/tb_top.sv 

vsim -coverage work.tb_top -voptargs="+acc" +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test3

add wave -r /*

run -all

#coverage report -assert -binrhs -details -cvg -codeAll