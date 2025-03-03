RV32I
ghdl -a --std=08 src/contador.vhd tb/tb_contador.vhd
ghdl -e --std=08 tb_contador
ghdl -r tb_contador --vcd=sim/contador/wave.vcd --stop-time=200ns
gtkwave sim/contador/wave.vcd sim/contador/signals.gtkw -S conf.tcl
./run_simulation.sh tb_pc 500ns
