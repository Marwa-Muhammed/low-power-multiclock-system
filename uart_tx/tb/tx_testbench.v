`timescale 1ns/1ps

module UART_Tx_tb ();

localparam DATA_WIDTH = 8 ;
localparam CLK_CYCLE = 5.0; //ns

reg [DATA_WIDTH - 1 : 0] P_DATA_tb;
reg DATA_VALID_tb;
reg PAR_EN_tb;
reg PAR_TYP_tb;
reg CLK_tb;
reg RST_tb;

wire Tx_out_tb;
wire Busy_tb;


initial begin
    CLK_tb = 0;
end
always  #(CLK_CYCLE/2) CLK_tb = ~CLK_tb;

task check_bit;
    input bit_val_exp;
begin
    if (Tx_out_tb === bit_val_exp) begin
        $display("    PASS: expected %b, got %b", bit_val_exp, Tx_out_tb);
    end else begin
        $display("    FAIL: expected %b, got %b", bit_val_exp, Tx_out_tb);
    end
end
endtask

task Reset_UART;

begin
    P_DATA_tb = 0;
    DATA_VALID_tb = 0;
    PAR_EN_tb = 0;
    PAR_TYP_tb = 0;

    RST_tb = 0;
    @(negedge CLK_tb)
    RST_tb = 1;
end    

endtask

task Send_and_check_Frame;
    input [7:0] data;
    input par_en;
    input par_typ;
    input corrupt_mid_frame;

    integer i;
    reg exp_parity;

begin
    exp_parity = par_typ ? ~(^data) : (^data);

    @(negedge CLK_tb);

    P_DATA_tb = data;
    PAR_EN_tb = par_en;
    PAR_TYP_tb = par_typ;
    DATA_VALID_tb = 1;

    $display("=====================================================");
    $display("[%0t] Sending Frame", $time);
    $display("    DATA     = %h (%b)", data, data);
    $display("    PAR_EN   = %b", par_en);
    $display("    PAR_TYP  = %b", par_typ);
    $display("-----------------------------------------------------");

    @(negedge CLK_tb);
    DATA_VALID_tb = 0;

    check_bit(1'b0); // start bit

    for (i = 0; i < 8; i = i + 1) begin
        @(negedge CLK_tb);
        check_bit(data[i]); //data bits
        if (corrupt_mid_frame && i == 3) begin
            P_DATA_tb = ~data;
            $display("    [mid-frame] P_DATA driven to %h while Busy=%b", ~data, Busy_tb);
        end
    end

    if (par_en) begin
        @(negedge CLK_tb);
        check_bit(exp_parity);
    end

    @(negedge CLK_tb);
    check_bit(1'b1); //stop bit

    @(negedge Busy_tb); // wait for transmission to actually complete


end
endtask




initial begin

    Reset_UART();

    Send_and_check_Frame('h55,0,0,0); //no parity

    Send_and_check_Frame('hAA,1,0,0);

    Send_and_check_Frame('hF0,1,1,0);

    Send_and_check_Frame('hA5,1,0,1); // corrupt P_DATA mid-frame, must NOT affect output


// ---- DATA_VALID pulsed mid-frame ==> check spec 5

$display("=====================================================");
$display("[%0t] Sending Frame (spurious DATA_VALID mid-frame test)", $time);

@(negedge CLK_tb);
 P_DATA_tb = 'h55; 
 PAR_EN_tb = 1;
 PAR_TYP_tb = 0;
 DATA_VALID_tb = 1;

$display("    DATA     = %h (%b)", P_DATA_tb, P_DATA_tb);
$display("    PAR_EN   = %b", PAR_EN_tb);
$display("    PAR_TYP  = %b", PAR_TYP_tb);
$display("-----------------------------------------------------");

@(negedge CLK_tb);
DATA_VALID_tb = 0;

check_bit(1'b0);   // start bit
@(negedge CLK_tb); check_bit(1'b1); // bit0 ==> data
@(negedge CLK_tb); check_bit(1'b0); 
@(negedge CLK_tb); check_bit(1'b1); 

P_DATA_tb = 8'h53;
DATA_VALID_tb = 1;
PAR_EN_tb = 1;
PAR_TYP_tb = 1;
 $display("    [mid-frame] DATA_VALID pulsed with P_DATA=51 while Busy=%b (must be ignored)", Busy_tb);

@(negedge CLK_tb); DATA_VALID_tb = 0; check_bit(1'b0); 
@(negedge CLK_tb); check_bit(1'b1); 
@(negedge CLK_tb); check_bit(1'b0); 
@(negedge CLK_tb); check_bit(1'b1); 
@(negedge CLK_tb); check_bit(1'b0); // bit7 
@(negedge CLK_tb); check_bit(1'b0); // parity bit
@(negedge CLK_tb); check_bit(1'b1); // stop bit
@(negedge Busy_tb);

    $display("=====================================================");
    $display("UART TEST COMPLETED");
    $display("=====================================================");

    $finish;

end



UART_Tx DUT (

.P_DATA(P_DATA_tb),
.DATA_VALID(DATA_VALID_tb),
.PAR_EN(PAR_EN_tb),
.PAR_TYP(PAR_TYP_tb),
.CLK(CLK_tb),
.RST(RST_tb),
.Tx_out(Tx_out_tb),
.Busy(Busy_tb)

);

    
endmodule