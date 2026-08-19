module deserializer #(
    parameter DATA_WIDTH = 8
) (
    input deserializer_en,
    input deserializer_in,
    input [5:0] Prescale,
    input [5:0] edge_counter_out,
    input CLK,
    input RST,

    output reg [DATA_WIDTH-1:0] P_DATA
);

always @(posedge CLK or negedge RST) begin

    if(!RST) begin
        P_DATA <= 0;
    end

    else if(deserializer_en) begin

        if(edge_counter_out == Prescale - 1) begin
            // Right-shift P_DATA by 1 and insert the new bit at the MSB (bit DATA_WIDTH-1).
            // Each bit shifts one position right per clock as later bits arrive, so the
            // first bit received (b0) ends up at P_DATA[0] once all DATA_WIDTH bits are in.
            P_DATA <= {deserializer_in, P_DATA[DATA_WIDTH-1:1]};
        end

    end

end
endmodule