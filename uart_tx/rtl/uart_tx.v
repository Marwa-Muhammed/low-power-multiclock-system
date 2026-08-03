module UART_Tx #(parameter DATA_WIDTH = 8) (
   
input [DATA_WIDTH - 1 : 0] P_DATA,
input DATA_VALID,
input PAR_EN,
input PAR_TYP,
input CLK,
input RST,

output Tx_out,
output Busy
    
);

wire ser_done,serializer_out,parity_calc_out,ser_en;

//
Tx_FSM u_Tx_FSM (

  .DATA_VALID(DATA_VALID),
  .PAR_EN(PAR_EN),
  .ser_done(ser_done),
  .CLK(CLK),
  .RST(RST),
  .serializer_out(serializer_out),
  .parity_calc_out(parity_calc_out),
  .TX_OUT(Tx_out),
  .ser_en(ser_en),
  .parity_calc_en(parity_calc_en),
  .Busy(Busy)

);
    
serializer #(
    .DATA_WIDTH(DATA_WIDTH)
)u_serializer(
    .P_DATA(P_DATA),
    .ser_en(ser_en),
    .CLK(CLK),
    .RST(RST),
    .serial_data(serializer_out),
    .ser_done(ser_done)

);

parity_calc #(
    .DATA_WIDTH(DATA_WIDTH)
) u_parity_calc (

    .P_DATA(P_DATA),
    .PAR_TYPE(PAR_TYP),
    .parity_calc_en(parity_calc_en),
    .CLK(CLK),
    .RST(RST),
    .parity_bit(parity_calc_out)

);



endmodule