module parity_calc #(parameter DATA_WIDTH = 8) (

    input [DATA_WIDTH - 1 : 0] P_DATA,
    input PAR_TYPE,
    input parity_calc_en,
    input CLK,
    input RST,

    output reg parity_bit
);
    

    always @ (posedge CLK or negedge RST ) begin
         if(!RST) begin
            parity_bit <= 1'b0;
         end
         else begin
            if (parity_calc_en) begin

            if (PAR_TYPE)  //odd parity
                parity_bit <= ~(^P_DATA);
            else 
                parity_bit <= (^P_DATA);  

         end
         end

    end
endmodule