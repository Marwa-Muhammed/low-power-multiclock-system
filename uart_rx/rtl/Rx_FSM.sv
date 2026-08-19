module Rx_FSM #(
   parameter DATA_WIDTH = 8            // Number of data bits per UART frame
) ( 
   input RX_IN,                        // Serial input line 
   input sampler_out,                  // Sampled value of RX_IN 
   input [5:0] Prescale,               // Number of edge_counter ticks per bit period
   input [3:0] bit_counter_out,        // Counts which data bit is currently being received
   input [5:0] edge_counter_out,       // Counts clock edges within the current bit period
   input parity_checker_out,           // Computed parity value to compare against received parity bit
   input PAR_EN,                       // Enables parity checking when set
   input CLK,
   input RST,                         

   output reg sampler_en,              
   output reg parity_checker_en,       
   output reg bit_counter_en,          
   output reg deserializer_en,         
   output reg deserializer_in,        
   output reg parity_error,            
   output reg stop_error,              
   output reg data_valid               
);

// FSM state encoding
typedef enum bit [2:0] {
    IDLE                = 3'b000,   // Waiting for RX_IN to fall (start bit)
    CHECK_START_BIT     = 3'b001,   // Confirming the start bit is valid
    DATA_BITS           = 3'b010,   // Shifting in DATA_WIDTH data bits
    CHECK_PARITY_BIT    = 3'b011,   // Sampling and checking the parity bit (only if PAR_EN)
    CHECK_STOP_BIT      = 3'b100,   // Sampling and checking the stop bit
    FRAME_END           = 3'b101    // Frame complete; data_valid pulses, checks for next start bit
} state_e;

state_e current_state, next_state; 

// Internal combinational error flags (drive the output ports at the end of the always block)
reg parity_error_comb;
reg stop_error_comb;

// Sequential state register

always @(posedge CLK or negedge RST) begin
    if(!RST) 
        current_state <= IDLE;    
    else
        current_state <= next_state;
end


// Combinational FSM logic: next-state and output decoding 
always @(*) begin
    // Default values every cycle to avoid unintended latches
    sampler_en        = 0;     
    parity_checker_en = 0;
    bit_counter_en    = 0;
    deserializer_en   = 0;
    deserializer_in   = 0;
    data_valid        = 0;
    parity_error_comb = 0;
    stop_error_comb   = 0;
    
    next_state = current_state;

    case (current_state)

        // Idle: wait for RX_IN to go low, signaling a potential start bit
        IDLE: begin
            if(!RX_IN) begin   
                sampler_en = 1;              
                next_state = CHECK_START_BIT;
            end
            else begin
                next_state = IDLE;           // Line still idle, keep waiting
            end
        end

        // Verify the start bit stays low at the mid-bit sample point
        CHECK_START_BIT: begin
            sampler_en = 1;  
            if (edge_counter_out == Prescale - 1) begin   // Reached sample time
                if(sampler_out == 0) begin
                    next_state = DATA_BITS;   // Valid start bit -> begin receiving data
                end    
                else begin
                    next_state = IDLE;        // False start (glitch) -> go back to idle
                end
            end else begin
                next_state = CHECK_START_BIT; // Still waiting 
            end
        end

        // Receive DATA_WIDTH data bits, one per bit period
        DATA_BITS: begin
            bit_counter_en  = 1;              
            sampler_en = 1;  
            deserializer_en = 1;             
            deserializer_in = sampler_out;    // Feed sampled bit into deserializer
   
            if(bit_counter_out == DATA_WIDTH - 1 && edge_counter_out == Prescale - 1) begin
                if (PAR_EN) begin
                    next_state = CHECK_PARITY_BIT;  // Parity enabled -> check parity next
                end else begin
                    next_state = CHECK_STOP_BIT;    // No parity -> go straight to stop bit
                end          
            end     
            else begin
                next_state  = DATA_BITS;      // Keep receiving remaining bits
            end
        end
        
        // Sample and validate the parity bit
        CHECK_PARITY_BIT: begin
            sampler_en        = 1;  
            parity_checker_en = 1; 
            
            if (edge_counter_out == Prescale - 1) begin   
                if(parity_checker_out == sampler_out) begin
                    next_state = CHECK_STOP_BIT;   // Parity matches -> proceed to stop bit
                end
                else begin
                    parity_error_comb = 1;         // Parity mismatch -> flag error immediately
                    next_state = IDLE;      
                end
            end
            else begin
                next_state = CHECK_PARITY_BIT;    
            end
        end    

        // Sample and validate the stop bit
        CHECK_STOP_BIT: begin
            sampler_en = 1;  
            if (edge_counter_out == Prescale - 1) begin   
                if(sampler_out == 1) begin
                    next_state = FRAME_END;        // Valid stop bit -> frame complete
                end
                else begin
                    stop_error_comb = 1;           // Stop bit not high -> framing error
                    next_state      = IDLE;         
                end
            end
            else begin
                next_state = CHECK_STOP_BIT;      
            end    
        end 

        // Frame successfully received; pulse data_valid and check for the next frame
        FRAME_END: begin
            data_valid = 1;                        // Signal that received byte is valid
            
            if (!RX_IN) begin
                sampler_en = 1;                     // Line already low -> next start bit begins immediately
                next_state = CHECK_START_BIT;
            end
            else begin
                next_state = IDLE;                  // Line idle -> return to IDLE and wait
            end
        end
         
        // Safety default for unreachable/undefined states
        default: begin
            next_state = IDLE;
        end

    endcase    

    // Drive the actual output ports from the internal combinational error flags
    parity_error = parity_error_comb;
    stop_error = stop_error_comb;
end

endmodule