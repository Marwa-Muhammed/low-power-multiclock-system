module edge_bit_counter #(
     parameter DATA_WIDTH = 8
) (
   input bit_counter_en,    // enabled only during DATA_BITS, so only real data bits are counted
   input [5:0] Prescale,    // oversampling ratio (8, 16, or 32) - number of CLK ticks per bit period
   input CLK,
   input RST,

   output reg [3:0] bit_counter_out,  // counts completed data bits within the current frame 
   output reg [5:0] edge_counter_out  // counts CLK ticks within the current bit period 
);

    always @(posedge CLK or negedge RST) begin

        if (!RST) begin
            bit_counter_out  <= 0;
            edge_counter_out <= 0;
        end

        else begin

            // when edge_counter_out reaches Prescale-1, one full bit period has compleated.
            if (edge_counter_out == Prescale - 1) begin

                // bit period complete ==> reset the edge counter for the next bit
                edge_counter_out <= 0;

                // increment bit_counter_out only if we're actually counting data bits
                if (bit_counter_en) begin
                    if (bit_counter_out == DATA_WIDTH - 1)
                        // all data bits received for this frame - roll over for next frame
                        bit_counter_out <= 0;
                    else
                        // one more data bit period has completed
                        bit_counter_out <= bit_counter_out + 1;
                end
            end
            else begin
                // still within the current bit period - keep counting CLK ticks
                edge_counter_out <= edge_counter_out + 1;
            end
        end

    end

endmodule