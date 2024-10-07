
module deserializer #(parameter DEPTH=8)
  (input i_Wclk, i_Wrst_n, i_W_en,
   input i_Rclk, i_Rrst_n, i_R_en,
   input i_Data_In,
   output reg [7:0] o_Data,
   output reg o_FIFO_Out,
   output reg o_full, o_empty);
 
  reg [9:0] r_Des_Data = 10'b0000000000;
  reg [9:0] r_Counter = 0;
  
  reg [2:0] r_3B = 3'b000;
  reg [4:0] r_5B = 5'b00000;
  reg [7:0] r_8B = 8'b00000000;
  reg r_Data_Ready = 1'b0;
  
  async_FIFO FIFO (.i_Wclk(i_Wclk), 
                   .i_Wrst_n(i_Wrst_n), 
                   .i_W_en(i_W_en), 
                   .i_Rclk(i_Rclk), 
                   .i_Rrst_n(i_Rrst_n), 
                   .i_R_en(i_R_en), 
                   .i_Data_In(i_Data_In), 
                   .o_Data_Out(o_FIFO_Out),
                   .o_full(o_full), 
                   .o_empty(o_empty));
  

  //deserializes the data
  always @(posedge i_Rclk) begin
    if (i_R_en) begin
      if (r_Counter < 10) begin 
        r_Des_Data[9] <= o_FIFO_Out; //put it in reverse order from recieved
        r_Des_Data[7:0] <= r_Des_Data[8:1];
      	r_Counter <= r_Counter + 1;
      end
    end
  end
  
  always @(posedge i_Rclk) begin
    if (r_Counter == 10) begin 
      r_Counter = 0;
      case (r_Des_Data[9:4])
        6'b100111 : r_5B <= 5'b00000;
        6'b011000 : r_5B <= 5'b00000;
        6'b011101 : r_5B <= 5'b00001;
        6'b100010 : r_5B <= 5'b00001;
        6'b101101 : r_5B <= 5'b00010;
        6'b010010 : r_5B <= 5'b00010;
        6'b110001 : r_5B <= 5'b00011;
        6'b110101 : r_5B <= 5'b00100;
        6'b001010 : r_5B <= 5'b00100;
        6'b101001 : r_5B <= 5'b00101;
        6'b011001 : r_5B <= 5'b00110;
        6'b111000 : r_5B <= 5'b00111;
        6'b000111 : r_5B <= 5'b00111;
        6'b111001 : r_5B <= 5'b01000;
        6'b000110 : r_5B <= 5'b01000;
        6'b100101 : r_5B <= 5'b01001;
        6'b010101 : r_5B <= 5'b01010;
        6'b110100 : r_5B <= 5'b01011;
        6'b001101 : r_5B <= 5'b01100;
        6'b101100 : r_5B <= 5'b01101;
        6'b011100 : r_5B <= 5'b01110;
        6'b010111 : r_5B <= 5'b01111;
        6'b101000 : r_5B <= 5'b01111;
        6'b011011 : r_5B <= 5'b10000;
        6'b100100 : r_5B <= 5'b10000;
        6'b100011 : r_5B <= 5'b10001;
        6'b010011 : r_5B <= 5'b10010;
        6'b110010 : r_5B <= 5'b10011;
        6'b001011 : r_5B <= 5'b10100;
        6'b101010 : r_5B <= 5'b10101;
        6'b011010 : r_5B <= 5'b10110;
        6'b111010 : r_5B <= 5'b10111;
        6'b000101 : r_5B <= 5'b10111;
        6'b110011 : r_5B <= 5'b11000;
        6'b001100 : r_5B <= 5'b11000;
        6'b100110 : r_5B <= 5'b11001;
        6'b010110 : r_5B <= 5'b11010;
        6'b110110 : r_5B <= 5'b11011;
        6'b001001 : r_5B <= 5'b11011;
        6'b001110 : r_5B <= 5'b11100;
        6'b101110 : r_5B <= 5'b11101;
        6'b010001 : r_5B <= 5'b11101;
        6'b011110 : r_5B <= 5'b11110;
        6'b100001 : r_5B <= 5'b11110;
        6'b101011 : r_5B <= 5'b11111;
        6'b010100 : r_5B <= 5'b11111;
        default : r_5B <= 5'b00000;
      endcase
      
      case (r_Des_Data[3:0]) 
        4'b1011 : r_3B <= 3'b000;
        4'b0100 : r_3B <= 3'b000;
        4'b1001 : r_3B <= 3'b001;
        4'b0101 : r_3B <= 3'b010;
        4'b1100 : r_3B <= 3'b011;
        4'b0011 : r_3B <= 3'b011;
        4'b1101 : r_3B <= 3'b100;
        4'b0010 : r_3B <= 3'b100;
        4'b1010 : r_3B <= 3'b101;
        4'b0110 : r_3B <= 3'b110;
        4'b1110 : r_3B <= 3'b111;
        4'b0001 : r_3B <= 3'b111;
        default : r_3B <= 3'b000;
      endcase  
    end
  end
  
  always @(r_5B, r_3B) begin 
    r_8B = {r_3B, r_5B}; //r_8B fully created
  end
  
  assign o_Data = r_8B;
endmodule