`timescale 1ns/1ps

module uart_rx_tb();

    reg RX_IN_tb;
    reg [5:0] Prescale_tb;
    reg PAR_EN_tb;
    reg PAR_TYP_tb;
    reg CLK_tb;
    reg RST_tb;

    wire [7:0] P_DATA_tb;
    wire data_valid_tb;
    wire parity_error_tb;
    wire stop_error_tb;

    // to latch flags 
    reg data_valid_seen;
    reg parity_error_seen;
    reg stop_error_seen;

    // TX bit period = 1 / 115200 = 8680.56 ns
    localparam real TX_BIT_PERIOD = 8680.56;

    // initialized safely with Prescale = 8
    real rx_clk_half_period = TX_BIT_PERIOD / 8 / 2.0;

    
    // Clock Generation
    initial begin
        CLK_tb = 0;
        forever #(rx_clk_half_period)
            CLK_tb = ~CLK_tb;
    end

    // Latch output flags 
    always @(*) begin
        if (data_valid_tb) begin
            data_valid_seen   = 1'b1;
            parity_error_seen = 1'b0;
            stop_error_seen   = 1'b0;
        end    
        if (parity_error_tb) begin
            data_valid_seen   = 1'b0;
            parity_error_seen = 1'b1;
            stop_error_seen   = 1'b0;
        end
        if (stop_error_tb) begin
            data_valid_seen   = 1'b0;
            parity_error_seen = 1'b0;
            stop_error_seen   = 1'b1;
        end
    end

    // Set Prescale

    task set_prescale;
        input [5:0] presc;
        begin
            Prescale_tb = presc;
            rx_clk_half_period = TX_BIT_PERIOD / presc / 2.0;
        end
    endtask

    
    // Reset UART
    
    task Reset_UART;
        begin
            RX_IN_tb   = 1'b1;
            PAR_EN_tb  = 1'b0;
            PAR_TYP_tb = 1'b0;
            Prescale_tb = 6'd8;
            RST_tb = 1'b0;
            #(TX_BIT_PERIOD);
            RST_tb = 1'b1;
        end
    endtask

    // Receive UART Frame with Auto-Check
    
    task receive_frame;
        input start_bit;
        input [7:0] RX_IN;
        input PAR_EN;
        input PAR_TYP;
        input parity_bit;
        input stop_bit;
        input [5:0] presc;

        input [7:0] exp_data;
        input exp_valid;
        input exp_parity_err;
        input exp_stop_err;
        
        reg case_passed;

        begin
            // Clear flags from previous test
            data_valid_seen   = 1'b0;
            parity_error_seen = 1'b0;
            stop_error_seen   = 1'b0;

            // Configuration
            PAR_EN_tb  = PAR_EN;
            PAR_TYP_tb = PAR_TYP;
            set_prescale(presc);

            // START BIT
            RX_IN_tb = start_bit;
            #(TX_BIT_PERIOD);

            // DATA BITS
            RX_IN_tb = RX_IN[0]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[1]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[2]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[3]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[4]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[5]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[6]; #(TX_BIT_PERIOD);
            RX_IN_tb = RX_IN[7]; #(TX_BIT_PERIOD);

            // PARITY BIT
            if (PAR_EN) begin
                RX_IN_tb = parity_bit;
                #(TX_BIT_PERIOD);
            end

            // STOP BIT
            RX_IN_tb = stop_bit;
            #(TX_BIT_PERIOD);


            // Self-checking logic conditions
            case_passed = 1'b1;
            if (exp_valid && (P_DATA_tb !== exp_data || !data_valid_seen)) case_passed = 1'b0;
            if (data_valid_seen !== exp_valid) case_passed = 1'b0;
            if (parity_error_seen !== exp_parity_err) case_passed = 1'b0;
            if (stop_error_seen !== exp_stop_err) case_passed = 1'b0;

            // Display Results
            $display("In: %b | Out: %b | Data_Valid: %b Parity_Error: %b Stop_Error: %b -> %s", 
                     RX_IN, P_DATA_tb, data_valid_seen, parity_error_seen, stop_error_seen, 
                     case_passed ? "PASSED" : "FAILED");
        end
    endtask

    initial begin
        Reset_UART();

        $display("==============================================================");
        $display("                    RUNNING UART RX TESTS                    ");
        $display("==============================================================");

        // Case 1: No Parity
        receive_frame(1'b0, 8'b10100101, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b10100101, 1'b1, 1'b0, 1'b0);

        // Case 2: No Parity
        receive_frame(1'b0, 8'b11110000, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b11110000, 1'b1, 1'b0, 1'b0);

        // Case 3: Even Parity Correct
        receive_frame(1'b0, 8'b11001100, 1'b1, 1'b0, 1'b0, 1'b1, 6'd8, 8'b11001100, 1'b1, 1'b0, 1'b0);

        // Case 4: Odd Parity Correct
        receive_frame(1'b0, 8'b11001100, 1'b1, 1'b1, 1'b1, 1'b1, 6'd8, 8'b11001100, 1'b1, 1'b0, 1'b0);

        // Case 5: All Zeros
        receive_frame(1'b0, 8'b00000000, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b00000000, 1'b1, 1'b0, 1'b0);

        // Case 6: All Ones
        receive_frame(1'b0, 8'b11111111, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b11111111, 1'b1, 1'b0, 1'b0);

        // Case 7: Single LSB - Even Parity
        receive_frame(1'b0, 8'b00000001, 1'b1, 1'b0, 1'b1, 1'b1, 6'd8, 8'b00000001, 1'b1, 1'b0, 1'b0);

        // Case 8: Single MSB - Odd Parity
        receive_frame(1'b0, 8'b10000000, 1'b1, 1'b1, 1'b0, 1'b1, 6'd8, 8'b10000000, 1'b1, 1'b0, 1'b0);

        // Case 9: Stop Error
        receive_frame(1'b0, 8'b01010101, 1'b0, 1'b0, 1'b0, 1'b0, 6'd8, 8'b01010101, 1'b0, 1'b0, 1'b1);

        // Case 10: Even Parity Error
        receive_frame(1'b0, 8'b11001100, 1'b1, 1'b0, 1'b1, 1'b1, 6'd8, 8'b11001100, 1'b0, 1'b1, 1'b0);

        // Case 11: Odd Parity Error
        receive_frame(1'b0, 8'b11001100, 1'b1, 1'b1, 1'b0, 1'b1, 6'd8, 8'b11001100, 1'b0, 1'b1, 1'b0);

        // Case 12: Prescale = 4
        receive_frame(1'b0, 8'b01100110, 1'b0, 1'b0, 1'b0, 1'b1, 6'd4, 8'b01100110, 1'b1, 1'b0, 1'b0);

        // Case 13: Prescale = 16
        receive_frame(1'b0, 8'b00111100, 1'b0, 1'b0, 1'b0, 1'b1, 6'd16, 8'b00111100, 1'b1, 1'b0, 1'b0);

        // Case 14: Prescale = 16 - Even Parity
        receive_frame(1'b0, 8'b00111100, 1'b1, 1'b0, 1'b0, 1'b1, 6'd16, 8'b00111100, 1'b1, 1'b0, 1'b0);

        // Case 15: Back-to-Back Frame 1
        receive_frame(1'b0, 8'b00001111, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b00001111, 1'b1, 1'b0, 1'b0);

        // Case 16: Back-to-Back Frame 2
        receive_frame(1'b0, 8'b11100001, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b11100001, 1'b1, 1'b0, 1'b0);

        // Case 17: Stop Error Recovery Test
        receive_frame(1'b0, 8'b01011010, 1'b0, 1'b0, 1'b0, 1'b0, 6'd8, 8'b01011010, 1'b0, 1'b0, 1'b1);

        // Case 18: Valid Frame After Error
        receive_frame(1'b0, 8'b10011001, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b10011001, 1'b1, 1'b0, 1'b0);

        // Case 19: Prescale = 32
        receive_frame(1'b0, 8'b10100101, 1'b0, 1'b0, 1'b0, 1'b1, 6'd32, 8'b10100101, 1'b1, 1'b0, 1'b0);

        // Case 20: Prescale = 32 - Parity Error
        receive_frame(1'b0, 8'b10100101, 1'b1, 1'b0, 1'b1, 1'b1, 6'd32, 8'b10100101, 1'b0, 1'b1, 1'b0);

           

        // Case 21: Deep Idle Test (Goes to IDLE for 3 bit periods before running data)
        // Forces line high (Idle) after previous checks finish, then sends normal frame.
        RX_IN_tb = 1'b1; 
        #(TX_BIT_PERIOD * 3); 
        receive_frame(1'b0, 8'b11011011, 1'b0, 1'b0, 1'b0, 1'b1, 6'd8, 8'b11011011, 1'b1, 1'b0, 1'b0);


        // Case 22: False Start Bit Glitch Test
        // Drops line to 0, but flips back to 1 before the middle sampling point (half a bit period).
        // The DUT should reject it, remain in IDLE, and NOT flag any data valid or error changes.
        
        // Clear flags from previous test
        data_valid_seen   = 1'b0;
        parity_error_seen = 1'b0;
        stop_error_seen   = 1'b0;  

        // Generate Glitch: Drop for 2 RX Clocks, then pull back up to 1 (Fails mid-bit validation check)
        RX_IN_tb = 1'b0;
        repeat(2) @(posedge CLK_tb); 
        RX_IN_tb = 1'b1;
        
        if (!data_valid_seen && !parity_error_seen && !stop_error_seen) begin
            $display("Glitch ignored successfully. -> PASSED");
        end else begin
            $display("Glitch caused false state transition! -> FAILED");
        end

        #(TX_BIT_PERIOD * 3); 

        $stop;   
        
         end

   
    uart_rx DUT (
        .RX_IN        (RX_IN_tb),
        .Prescale     (Prescale_tb),
        .PAR_EN       (PAR_EN_tb),
        .PAR_TYP      (PAR_TYP_tb),
        .CLK          (CLK_tb),
        .RST          (RST_tb),
        .P_DATA       (P_DATA_tb),
        .data_valid   (data_valid_tb),
        .parity_error (parity_error_tb),
        .stop_error   (stop_error_tb)
    );

endmodule