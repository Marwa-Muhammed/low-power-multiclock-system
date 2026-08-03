onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /UART_Tx_tb/P_DATA_tb
add wave -noupdate /UART_Tx_tb/DATA_VALID_tb
add wave -noupdate /UART_Tx_tb/DUT/ser_en
add wave -noupdate /UART_Tx_tb/DUT/ser_done
add wave -noupdate -color Red /UART_Tx_tb/Busy_tb
add wave -noupdate /UART_Tx_tb/Tx_out_tb
add wave -noupdate -color Cyan /UART_Tx_tb/CLK_tb
add wave -noupdate /UART_Tx_tb/RST_tb
add wave -noupdate /UART_Tx_tb/PAR_EN_tb
add wave -noupdate /UART_Tx_tb/PAR_TYP_tb
add wave -noupdate /UART_Tx_tb/DUT/u_Tx_FSM/parity_calc_en
add wave -noupdate /UART_Tx_tb/DUT/u_Tx_FSM/current_state
add wave -noupdate /UART_Tx_tb/DUT/u_Tx_FSM/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51767 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
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
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {241425 ps} {293357 ps}
