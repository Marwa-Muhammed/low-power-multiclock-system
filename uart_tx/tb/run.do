vlib work
vlog -sv *.v
vsim -voptargs=+acc work.UART_Tx_tb
do wave.do
run -all