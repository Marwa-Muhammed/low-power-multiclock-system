vlib work
vlog -sv *.v
vsim -voptargs=+acc work.uart_rx_tb
do wave.do
run -all