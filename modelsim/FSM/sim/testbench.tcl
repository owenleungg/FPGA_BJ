# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work

# compile the Verilog source code in the parent folder
vlog ../../../src/verilog/game_logic/blackjack_top.v ../../../src/verilog/game_logic/blackjack_fsm.v ../../../src/verilog/game_logic/button_debouncer.v ../../../src/verilog/game_logic/char_7seg.v ../../../src/verilog/game_logic/card_rng.v

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator, including some libraries that may be needed
vsim work.testbench -Lf 220model -Lf altera_mf_ver -Lf verilog

# show waveforms specified in wave.do
do wave.do

# advance the simulation the desired amount of time
run 1000 ns