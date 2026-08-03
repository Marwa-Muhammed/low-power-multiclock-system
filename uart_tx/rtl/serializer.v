module serializer #(parameter DATA_WIDTH = 8) (
   
input [DATA_WIDTH - 1 : 0] P_DATA,
input ser_en,
input CLK,
input RST,
output reg serial_data,
output reg ser_done

);
    
reg [$clog2(DATA_WIDTH)-1:0] counter;
reg [DATA_WIDTH-1:0] data_reg;

always @(posedge CLK or negedge RST) begin    
    if (!RST) begin
      counter <= 0;
      ser_done <= 0; 
      serial_data <= 1;
      data_reg <= 0;

    end

    else if (ser_en) begin

        // Latch P_DATA once at counter==0 so the frame can't be corrupted
        // if P_DATA changes on the bus mid-transmission 
            
        if (counter == 0) data_reg <= P_DATA;
        //counter==0 still reads P_DATA directly since data_reg isn't updated until next cycle
        serial_data <= (counter == 0) ? P_DATA[counter] : data_reg[counter];
  
        if (counter == DATA_WIDTH-1) begin
            counter <= 0;
            ser_done <= 1;
        end
        else begin
            counter <= counter + 1;
            ser_done <= 0;
        end
    end
    else begin
        serial_data <= 1;
        counter <= 0;
        ser_done <= 0;
    end
end


endmodule