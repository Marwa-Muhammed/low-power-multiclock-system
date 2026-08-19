onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_rx_tb/DUT/RST
add wave -noupdate -radix decimal /uart_rx_tb/DUT/fsm_inst/Prescale
add wave -noupdate /uart_rx_tb/DUT/CLK
add wave -noupdate -color Turquoise /uart_rx_tb/DUT/RX_IN
add wave -noupdate -expand -group Sampler_Signals -color Gold /uart_rx_tb/DUT/sampler_en
add wave -noupdate -expand -group Sampler_Signals /uart_rx_tb/DUT/sampler_out
add wave -noupdate -expand -group Deserializer_Signals -color Gold /uart_rx_tb/DUT/deserializer_en
add wave -noupdate -expand -group Deserializer_Signals /uart_rx_tb/DUT/deserializer_in
add wave -noupdate -expand -group P_DATA -radix binary /uart_rx_tb/DUT/P_DATA
add wave -noupdate -expand -group P_DATA -color Red /uart_rx_tb/DUT/data_valid
add wave -noupdate -expand -group Rx_Flags /uart_rx_tb/DUT/parity_error
add wave -noupdate -expand -group Rx_Flags /uart_rx_tb/DUT/stop_error
add wave -noupdate -expand -group Counter_Signals -color Gold /uart_rx_tb/DUT/bit_counter_en
add wave -noupdate -expand -group Counter_Signals -color White -radix unsigned /uart_rx_tb/DUT/bit_counter_out
add wave -noupdate -expand -group Counter_Signals -color White -radix unsigned /uart_rx_tb/DUT/edge_counter_out
add wave -noupdate -expand -group Parity_Signals -color Gold /uart_rx_tb/DUT/parity_checker_en
add wave -noupdate -expand -group Parity_Signals -color Blue /uart_rx_tb/DUT/parity_checker_out
add wave -noupdate /uart_rx_tb/DUT/fsm_inst/current_state
add wave -noupdate /uart_rx_tb/DUT/fsm_inst/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 8680560
configure wave -griddelta 50
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {116404449 ps}
