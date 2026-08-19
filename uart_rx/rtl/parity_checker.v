module parity_checker #(
     parameter DATA_WIDTH = 8
) (
    input parity_checker_en,
    input PAR_TYP,
    input [DATA_WIDTH-1:0] P_DATA,
    input CLK,
    input RST,

    output reg parity_checker_out
);

  localparam EVEN_PARITY = 0,
             ODD_PARITY  = 1;   


    always @(posedge CLK or negedge RST ) begin

        if(!RST) begin
           parity_checker_out <= 0; 
        end
        else if(parity_checker_en) begin
            case (PAR_TYP)

                EVEN_PARITY: parity_checker_out <= ^P_DATA;
                ODD_PARITY : parity_checker_out <= ~(^P_DATA);

                default: parity_checker_out <= 0;
            endcase
        end
        else begin
            parity_checker_out <= 0;
        end

    end
endmodule