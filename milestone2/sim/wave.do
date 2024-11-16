onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label card_value -radix binary /testbench/n/card_value
add wave -noupdate -label HEX0 -radix hexadecimal /testbench/n/HEX0
add wave -noupdate -label HEX1 -radix hexadecimal /testbench/n/HEX1
add wave -noupdate -label HEX2 -radix hexadecimal /testbench/n/HEX2
add wave -noupdate -label HEX3 -radix hexadecimal /testbench/n/HEX3
add wave -noupdate -label HEX4 -radix hexadecimal /testbench/n/HEX4
add wave -noupdate -label HEX5 -radix hexadecimal /testbench/n/HEX5

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {160 ns}
