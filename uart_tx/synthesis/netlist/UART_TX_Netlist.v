/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : O-2018.06-SP1
// Date      : Fri Aug  7 23:43:45 2026
/////////////////////////////////////////////////////////////


module Tx_FSM ( DATA_VALID, PAR_EN, ser_done, CLK, RST, serializer_out, 
        parity_calc_out, TX_OUT, ser_en, parity_calc_en, Busy );
  input DATA_VALID, PAR_EN, ser_done, CLK, RST, serializer_out,
         parity_calc_out;
  output TX_OUT, ser_en, parity_calc_en, Busy;
  wire   n23, n24, n4, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18,
         n19, n20, n3, n5, n22;
  wire   [2:0] current_state;

  DFFRQX2M \current_state_reg[0]  ( .D(n20), .CK(CLK), .RN(RST), .Q(
        current_state[0]) );
  DFFRQX2M \current_state_reg[1]  ( .D(n19), .CK(CLK), .RN(RST), .Q(
        current_state[1]) );
  DFFRX4M \current_state_reg[2]  ( .D(n18), .CK(CLK), .RN(RST), .QN(n4) );
  CLKBUFX8M U3 ( .A(n24), .Y(Busy) );
  XOR2X1M U4 ( .A(n11), .B(n4), .Y(n16) );
  OAI21X2M U5 ( .A0(n16), .A1(n17), .B0(n7), .Y(n24) );
  CLKBUFX8M U6 ( .A(n23), .Y(TX_OUT) );
  NAND3X3M U7 ( .A(n5), .B(n4), .C(current_state[1]), .Y(n12) );
  OAI2B11X2M U8 ( .A1N(serializer_out), .A0(n12), .B0(n4), .C0(n15), .Y(n23)
         );
  INVX2M U9 ( .A(current_state[0]), .Y(n5) );
  NOR2X4M U10 ( .A(n5), .B(n22), .Y(n11) );
  OAI211X2M U11 ( .A0(n3), .A1(n22), .B0(n13), .C0(n8), .Y(n19) );
  INVX2M U12 ( .A(n10), .Y(n3) );
  INVX2M U13 ( .A(n7), .Y(ser_en) );
  AOI22X1M U14 ( .A0(parity_calc_out), .A1(n11), .B0(n5), .B1(n22), .Y(n15) );
  INVX4M U15 ( .A(current_state[1]), .Y(n22) );
  CLKXOR2X2M U16 ( .A(current_state[0]), .B(current_state[1]), .Y(n17) );
  NAND2X2M U17 ( .A(n17), .B(n4), .Y(n7) );
  OAI22X4M U18 ( .A0(ser_done), .A1(n12), .B0(current_state[1]), .B1(
        DATA_VALID), .Y(n10) );
  NAND3BX2M U19 ( .AN(n12), .B(n3), .C(PAR_EN), .Y(n13) );
  INVX2M U20 ( .A(n8), .Y(parity_calc_en) );
  NAND2X2M U21 ( .A(n14), .B(n13), .Y(n20) );
  NAND4X2M U22 ( .A(n3), .B(n5), .C(n22), .D(n4), .Y(n14) );
  NOR2X2M U23 ( .A(n9), .B(n10), .Y(n18) );
  AOI2BB2X1M U24 ( .B0(n11), .B1(n4), .A0N(n12), .A1N(PAR_EN), .Y(n9) );
  NAND3X2M U25 ( .A(n22), .B(n4), .C(current_state[0]), .Y(n8) );
endmodule


module serializer ( P_DATA, ser_en, CLK, RST, serial_data, ser_done );
  input [7:0] P_DATA;
  input ser_en, CLK, RST;
  output serial_data, ser_done;
  wire   N5, N6, N7, N12, N13, N23, N24, N25, N26, n5, n6, n7, n8, n9, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n1, n2, n3, n4, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35;
  wire   [7:0] data_reg;

  DFFRQX2M ser_done_reg ( .D(N24), .CK(CLK), .RN(RST), .Q(ser_done) );
  DFFRQX2M \data_reg_reg[2]  ( .D(n13), .CK(CLK), .RN(RST), .Q(data_reg[2]) );
  DFFRQX2M \data_reg_reg[6]  ( .D(n17), .CK(CLK), .RN(RST), .Q(data_reg[6]) );
  DFFRQX2M \data_reg_reg[3]  ( .D(n14), .CK(CLK), .RN(RST), .Q(data_reg[3]) );
  DFFRQX2M \data_reg_reg[7]  ( .D(n18), .CK(CLK), .RN(RST), .Q(data_reg[7]) );
  DFFRQX2M \data_reg_reg[4]  ( .D(n15), .CK(CLK), .RN(RST), .Q(data_reg[4]) );
  DFFRQX2M \data_reg_reg[0]  ( .D(n19), .CK(CLK), .RN(RST), .Q(data_reg[0]) );
  DFFRQX2M \data_reg_reg[1]  ( .D(n12), .CK(CLK), .RN(RST), .Q(data_reg[1]) );
  DFFRQX2M \data_reg_reg[5]  ( .D(n16), .CK(CLK), .RN(RST), .Q(data_reg[5]) );
  DFFSQX2M serial_data_reg ( .D(N23), .CK(CLK), .SN(RST), .Q(serial_data) );
  DFFRQX4M \counter_reg[0]  ( .D(N25), .CK(CLK), .RN(RST), .Q(N5) );
  DFFRX4M \counter_reg[1]  ( .D(N26), .CK(CLK), .RN(RST), .Q(N6), .QN(n30) );
  DFFRX4M \counter_reg[2]  ( .D(n34), .CK(CLK), .RN(RST), .Q(N7), .QN(n29) );
  AOI32X1M U3 ( .A0(n35), .A1(N5), .A2(N6), .B0(N7), .B1(n35), .Y(n7) );
  NAND3X2M U4 ( .A(N6), .B(N5), .C(N7), .Y(n10) );
  NOR3X6M U5 ( .A(N6), .B(N7), .C(N5), .Y(n6) );
  NOR2X4M U6 ( .A(N5), .B(N6), .Y(n22) );
  NOR2X4M U7 ( .A(n30), .B(n31), .Y(n25) );
  NOR2X4M U8 ( .A(n31), .B(N6), .Y(n23) );
  AOI221X2M U9 ( .A0(P_DATA[2]), .A1(n26), .B0(P_DATA[3]), .B1(n25), .C0(n24), 
        .Y(n27) );
  AOI221X2M U10 ( .A0(P_DATA[6]), .A1(n26), .B0(P_DATA[7]), .B1(n25), .C0(n21), 
        .Y(n28) );
  AOI221X2M U11 ( .A0(data_reg[2]), .A1(n26), .B0(data_reg[3]), .B1(n25), .C0(
        n3), .Y(n4) );
  AOI221X2M U12 ( .A0(data_reg[6]), .A1(n26), .B0(data_reg[7]), .B1(n25), .C0(
        n2), .Y(n20) );
  NOR2X4M U13 ( .A(n30), .B(N5), .Y(n26) );
  AO22XLM U14 ( .A0(P_DATA[5]), .A1(n23), .B0(P_DATA[4]), .B1(n22), .Y(n21) );
  AO22XLM U15 ( .A0(P_DATA[1]), .A1(n23), .B0(P_DATA[0]), .B1(n22), .Y(n24) );
  AO22XLM U16 ( .A0(data_reg[1]), .A1(n23), .B0(data_reg[0]), .B1(n22), .Y(n3)
         );
  AO22XLM U17 ( .A0(data_reg[5]), .A1(n23), .B0(data_reg[4]), .B1(n22), .Y(n2)
         );
  BUFX4M U18 ( .A(n5), .Y(n1) );
  INVX4M U19 ( .A(n1), .Y(n33) );
  NAND2X2M U20 ( .A(ser_en), .B(n10), .Y(n8) );
  NAND2X2M U21 ( .A(ser_en), .B(n6), .Y(n5) );
  NOR2BX2M U22 ( .AN(ser_en), .B(n10), .Y(N24) );
  NAND2X2M U23 ( .A(n11), .B(ser_en), .Y(N23) );
  AOI22X1M U24 ( .A0(N12), .A1(n6), .B0(N13), .B1(n32), .Y(n11) );
  INVX2M U25 ( .A(n6), .Y(n32) );
  AO22X1M U26 ( .A0(P_DATA[0]), .A1(n33), .B0(data_reg[0]), .B1(n1), .Y(n19)
         );
  AO22X1M U27 ( .A0(P_DATA[7]), .A1(n33), .B0(data_reg[7]), .B1(n1), .Y(n18)
         );
  AO22X1M U28 ( .A0(P_DATA[6]), .A1(n33), .B0(data_reg[6]), .B1(n1), .Y(n17)
         );
  AO22X1M U29 ( .A0(P_DATA[5]), .A1(n33), .B0(data_reg[5]), .B1(n1), .Y(n16)
         );
  AO22X1M U30 ( .A0(P_DATA[4]), .A1(n33), .B0(data_reg[4]), .B1(n1), .Y(n15)
         );
  AO22X1M U31 ( .A0(P_DATA[3]), .A1(n33), .B0(data_reg[3]), .B1(n1), .Y(n14)
         );
  AO22X1M U32 ( .A0(P_DATA[2]), .A1(n33), .B0(data_reg[2]), .B1(n1), .Y(n13)
         );
  AO22X1M U33 ( .A0(P_DATA[1]), .A1(n33), .B0(data_reg[1]), .B1(n1), .Y(n12)
         );
  INVX2M U34 ( .A(N5), .Y(n31) );
  NOR2X2M U35 ( .A(N5), .B(n8), .Y(N25) );
  NOR2X2M U36 ( .A(n9), .B(n8), .Y(N26) );
  XNOR2X2M U37 ( .A(N6), .B(N5), .Y(n9) );
  INVX2M U38 ( .A(n7), .Y(n34) );
  INVX2M U39 ( .A(n8), .Y(n35) );
  OAI22X1M U40 ( .A0(n29), .A1(n20), .B0(N7), .B1(n4), .Y(N13) );
  OAI22X1M U41 ( .A0(n28), .A1(n29), .B0(N7), .B1(n27), .Y(N12) );
endmodule


module parity_calc ( P_DATA, PAR_TYPE, parity_calc_en, CLK, RST, parity_bit );
  input [7:0] P_DATA;
  input PAR_TYPE, parity_calc_en, CLK, RST;
  output parity_bit;
  wire   n1, n3, n4, n5, n6, n7, n2;

  DFFRQX2M parity_bit_reg ( .D(n7), .CK(CLK), .RN(RST), .Q(parity_bit) );
  XOR3XLM U2 ( .A(P_DATA[5]), .B(P_DATA[4]), .C(n6), .Y(n3) );
  CLKXOR2X2M U3 ( .A(P_DATA[7]), .B(P_DATA[6]), .Y(n6) );
  XOR3XLM U4 ( .A(P_DATA[1]), .B(P_DATA[0]), .C(n5), .Y(n4) );
  XNOR2X2M U5 ( .A(P_DATA[3]), .B(P_DATA[2]), .Y(n5) );
  OAI2BB2X1M U6 ( .B0(n1), .B1(n2), .A0N(parity_bit), .A1N(n2), .Y(n7) );
  INVX2M U7 ( .A(parity_calc_en), .Y(n2) );
  XOR3XLM U8 ( .A(n3), .B(PAR_TYPE), .C(n4), .Y(n1) );
endmodule


module UART_Tx ( P_DATA, DATA_VALID, PAR_EN, PAR_TYP, CLK, RST, Tx_out, Busy
 );
  input [7:0] P_DATA;
  input DATA_VALID, PAR_EN, PAR_TYP, CLK, RST;
  output Tx_out, Busy;
  wire   ser_done, serializer_out, parity_calc_out, ser_en, parity_calc_en;

  Tx_FSM u_Tx_FSM ( .DATA_VALID(DATA_VALID), .PAR_EN(PAR_EN), .ser_done(
        ser_done), .CLK(CLK), .RST(RST), .serializer_out(serializer_out), 
        .parity_calc_out(parity_calc_out), .TX_OUT(Tx_out), .ser_en(ser_en), 
        .parity_calc_en(parity_calc_en), .Busy(Busy) );
  serializer u_serializer ( .P_DATA(P_DATA), .ser_en(ser_en), .CLK(CLK), .RST(
        RST), .serial_data(serializer_out), .ser_done(ser_done) );
  parity_calc u_parity_calc ( .P_DATA(P_DATA), .PAR_TYPE(PAR_TYP), 
        .parity_calc_en(parity_calc_en), .CLK(CLK), .RST(RST), .parity_bit(
        parity_calc_out) );
endmodule

