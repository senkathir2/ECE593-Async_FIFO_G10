if [file exists "work" ] {vdel -all}

vlib work

vlog ./rtl/hw_top.sv ./TRAD_TB/*.sv

vsim work.top

run -all