RV32I
ghdl -a --std=08 src/contador.vhd tb/tb_contador.vhd
ghdl -e --std=08 tb_contador
ghdl -r tb_contador --wave=sim/contador/wave.ghw --stop-time=200ns
gtkwave sim/contador/wave.ghw sim/contador/signals.gtkw -S conf.tcl
./run.sh tb_pc 500ns
