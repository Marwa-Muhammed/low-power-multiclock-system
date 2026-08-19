module uart_rx #(
   parameter DATA_WIDTH = 8
) (
    input RX_IN,              //serial input come from Tx
    input [5:0] Prescale,     // UART configurations 
    input PAR_EN,
    input PAR_TYP,
    input CLK,
    input RST,

    output [DATA_WIDTH-1:0] P_DATA,
    output data_valid,
    output parity_error,
    output stop_error
);

//internal wires required for connections 
wire        sampler_out;
wire [3:0]  bit_counter_out;
wire        parity_checker_out;
wire        sampler_en;
wire        parity_checker_en;
wire        bit_counter_en;
wire        deserializer_en;
wire        deserializer_in;
wire [5:0]  edge_counter_out;


//instantiation
Rx_FSM fsm_inst (
    .RX_IN(RX_IN),
    .sampler_out(sampler_out),
    .Prescale(Prescale),
    .edge_counter_out(edge_counter_out),
    .bit_counter_out(bit_counter_out),
    .parity_checker_out(parity_checker_out),
    .PAR_EN(PAR_EN),
    .CLK(CLK),
    .RST(RST),
    .sampler_en(sampler_en),
    .parity_checker_en(parity_checker_en),
    .bit_counter_en(bit_counter_en),
    .deserializer_en(deserializer_en),
    .deserializer_in(deserializer_in),
    .parity_error(parity_error),
    .stop_error(stop_error),
    .data_valid(data_valid)
);

deserializer deser_inst(
    .deserializer_en(deserializer_en),
    .deserializer_in(deserializer_in),
    .Prescale(Prescale),
    .edge_counter_out(edge_counter_out),
    .CLK(CLK),
    .RST(RST),
    .P_DATA(P_DATA)
);

parity_checker par_inst(
    .parity_checker_en(parity_checker_en),
    .P_DATA(P_DATA),
    .PAR_TYP(PAR_TYP),
    .CLK(CLK),
    .RST(RST),
    .parity_checker_out(parity_checker_out)
);
   

edge_bit_counter cnt_inst(
    .bit_counter_en(bit_counter_en),
    .Prescale(Prescale),
    .CLK(CLK),
    .RST(RST),
    .bit_counter_out(bit_counter_out),
    .edge_counter_out(edge_counter_out)
);


sampler samp_inst(
    .RX_IN(RX_IN),
    .Prescale(Prescale),
    .sampler_en(sampler_en),
    .edge_counter_out(edge_counter_out),
    .CLK(CLK),
    .RST(RST),
    .sampler_out(sampler_out)
);


endmodule