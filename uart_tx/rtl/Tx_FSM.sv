module Tx_FSM(
    input DATA_VALID,
    input PAR_EN,
    input ser_done,
    input CLK,
    input RST,
    input serializer_out,
    input parity_calc_out,
 
    output reg TX_OUT,
    output reg ser_en,
    output reg parity_calc_en,
    output reg Busy
);

 
typedef enum bit [2:0] {

    IDLE        = 3'b000,
    FRAME_START = 3'b001,
    DATA_BITS   = 3'b010,
    PARITY      = 3'b011,
    FRAME_END   = 3'b100

} state_e;


state_e current_state, next_state;


always @(posedge CLK or negedge RST) begin
    if (!RST)
        current_state <= IDLE;
    else
        current_state <= next_state;
end


always @(*) begin
    //default values to avoid latches
    Busy = 0;
    ser_en     = 0;
    parity_calc_en = 0;   // Default OFF
    next_state = current_state;
    TX_OUT     = 1;


    case (current_state)

        IDLE: begin
            if(DATA_VALID) begin
                next_state = FRAME_START;
            end 
        end

        FRAME_START : begin
             
             Busy = 1;
             TX_OUT = 0; //start bit
             ser_en = 1;
             parity_calc_en = 1;   
             next_state = DATA_BITS;
             
            
        end

        DATA_BITS : begin
            //serializer work 8 clk cycles
            ser_en = 1;
            Busy = 1;
            TX_OUT = serializer_out; 

            if(ser_done) begin
                if (PAR_EN)
                    next_state = PARITY;
                else
                    next_state = FRAME_END;
                end
            
        end

        PARITY : begin
            Busy = 1;
            TX_OUT = parity_calc_out; 
            next_state = FRAME_END;

        end

        FRAME_END : begin
            Busy = 1;
            TX_OUT = 1; //stop bit
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;

        end
    endcase
    
end











endmodule