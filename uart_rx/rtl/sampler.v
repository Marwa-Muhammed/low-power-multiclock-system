module sampler #(
    parameter DATA_WIDTH = 8
) (
    input RX_IN,                
    input [5:0] Prescale,        
    input sampler_en,            
    input [5:0] edge_counter_out, 
    input CLK,
    input RST,                 

    output reg sampler_out        
);

    reg first_sample, second_sample;   // Store first two votes for majority-vote sampling

    // For mid-bit sampling keep sampling_methodology = 1; 
    // for majority-vote change it to sampling_methodology = 0.
    parameter sampling_methodology = 0;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            sampler_out   <= 0;
            first_sample  <= 0;
            second_sample <= 0;
        end
        else if (sampler_en) begin
            if (sampling_methodology) begin
                // ---------------------------------------------------------
                // Mid-Bit Single Point Sampling:
                // Capture RX_IN once, exactly at the midpoint of the bit
                // period (edge_counter_out == Prescale/2), for each
                // supported Prescale value.
                // ---------------------------------------------------------
                case (Prescale)
                    4:  if (edge_counter_out == 2)  sampler_out <= RX_IN;
                    8:  if (edge_counter_out == 4)  sampler_out <= RX_IN;
                    16: if (edge_counter_out == 8)  sampler_out <= RX_IN;
                    32: if (edge_counter_out == 16) sampler_out <= RX_IN;
                    default: 
                        sampler_out <= 0;  // Unsupported Prescale -> default low
                endcase
            end
            else begin
                // ---------------------------------------------------------
                // Majority-Vote Sampling:
                // Take 3 consecutive samples straddling the bit midpoint
                // (first_sample, second_sample, and current RX_IN), then
                // output whichever value at least 2 of the 3 agree on.
                // This rejects single-sample glitches/noise near the
                // sampling point.
                // ---------------------------------------------------------
                case (Prescale)
                    4: begin
                        if (edge_counter_out == 0) first_sample  <= RX_IN;  // Vote 1
                        if (edge_counter_out == 1) second_sample <= RX_IN;  // Vote 2
                        if (edge_counter_out == 2) begin                    // Vote 3 + majority decision
                            sampler_out <= (first_sample & second_sample) | 
                                           (first_sample & RX_IN) | 
                                           (second_sample & RX_IN);
                        end
                    end

                    8: begin
                        if (edge_counter_out == 3) first_sample  <= RX_IN;  
                        if (edge_counter_out == 4) second_sample <= RX_IN;  
                        if (edge_counter_out == 5) begin                    
                            sampler_out <= (first_sample & second_sample) | 
                                           (first_sample & RX_IN) | 
                                           (second_sample & RX_IN);
                        end
                    end

                    16: begin
                        if (edge_counter_out == 7)  first_sample  <= RX_IN; 
                        if (edge_counter_out == 8)  second_sample <= RX_IN; 
                        if (edge_counter_out == 9)  begin                   
                            sampler_out <= (first_sample & second_sample) | 
                                           (first_sample & RX_IN) | 
                                           (second_sample & RX_IN);
                        end
                    end

                    32: begin
                        if (edge_counter_out == 15) first_sample  <= RX_IN;  
                        if (edge_counter_out == 16) second_sample <= RX_IN;  
                        if (edge_counter_out == 17) begin                   
                            sampler_out <= (first_sample & second_sample) | 
                                           (first_sample & RX_IN) | 
                                           (second_sample & RX_IN);
                        end
                    end
                    default: sampler_out <= 0;   // Unsupported Prescale -> default low
                endcase
            end
        end
    end

endmodule