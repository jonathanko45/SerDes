// Code your design here
module SerDes_Project
  (input i_Clk,
   input i_Clk_Fast,
   input [31:0] i_Data, 
   input signed [1:0] i_RD,
   output [31:0] o_Ser_Data);
  
  localparam DEPTH = 32; //size of text coming in 
  
  reg [1:0] r_RD = i_RD;
  reg [3:0] r_4B;
  reg [5:0] r_6B;
  reg [9:0] r_10B;
  
  reg [31:0] r1_Data; //2 registers for speeding up data
  reg [31:0] r2_Data;

  wire [$clog2(DEPTH)-1:0] [7:0] w_Byte_Data = i_Data; //divides into 2D array
  
  //HGF EDCBA     <-- comes in
  //ABCDE   FGH   <-- rearrange
  //abcde i fgh i <-- according to disparity
  
  //always @(posedge i_Clk) begin
  always @(*) begin //always @(*) makes a change whenever anything inside changes
 	//big case statement here to get the data in order for RD
  	
  case (w_Byte_Data[0][4:0])
    5'b00000 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b100111;
      else if (i_RD == 1'b1)
        r_6B <= 011000;
    end
    5'b00001 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b011101;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b100010;
    end  
    5'b00010 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b101101;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b010010;
    end
    5'b00011 : r_6B <= 6'b110001;
    5'b00100 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b110101;
      else if (i_RD == 1'b1)
        r_6B <= 6'b001010;
    end
    5'b00101 : r_6B <= 6'b101001;
    5'b00110 : r_6B <= 6'b011001;
    5'b00111 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b111000;
      else if (i_RD == 1'b1)
        r_6B <= 6'b000111;
    end
    5'b01000 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b111001;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b000110;
    end
    5'b01001 : r_6B <= 6'b100101;
    5'b01010 : r_6B <= 6'b010101;
    5'b01011 : r_6B <= 6'b110100;
    5'b01100 : r_6B <= 6'b001101;
    5'b01101 : r_6B <= 6'b101100;
    5'b01110 : r_6B <= 6'b011100;
    5'b01111 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b010111;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b101000;
    end
    5'b10000 : begin
      if (i_RD == 2'sb11) 
        r_6B <= 6'b011011;
      else if (i_RD == 1'b1)
        r_6B <= 6'b100100;
    end
    5'b10001 : r_6B <= 6'b100011;
    5'b10010 : r_6B <= 6'b010011;
    5'b10011 : r_6B <= 6'b110010;
    5'b10100 : r_6B <= 6'b001011;
    5'b10101 : r_6B <= 6'b101010;
    5'b10110 : r_6B <= 6'b011010;
    5'b10111 : begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b111010;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b000101;
    end
    5'b11000 :begin
      if (i_RD == 2'sb11)
        r_6B <= 6'b110011;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b001100;
    end
    5'b11001 : r_6B <= 6'b100110;
    5'b11010 : r_6B <= 6'b010110;
    5'b11011 : begin
      if (i_RD == 2'sb11) 
        r_6B <= 6'b110110;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b001001;
    end
    5'b11100 : r_6B <= 6'b001110;
    5'b11101 : begin
      if (i_RD == 2'sb11) 
        r_6B <= 6'b101110;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b010001;
    end
    5'b11110 : begin
      if (i_RD == 2'sb11) 
        r_6B <= 6'b011110;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b100001;
    end
    5'b11111 : begin
      if (i_RD == 2'sb11) 
        r_6B <= 6'b101011;
      else if (i_RD == 1'b1) 
        r_6B <= 6'b010100;
    end
    default : r_6B <= 6'b000000;
  endcase
      
  
  
// ##### 3b/4b ####
  case (w_Byte_Data[0][7:5])
    3'b000 : begin
      if (i_RD == 2'sb11)
        r_4B <= 4'b1011;
      else if (i_RD == 1'b1) 
        r_4B <= 4'b0100;
    end
    3'b001 : r_4B <= 4'b1001;
    3'b010 : r_4B <= 4'b0101;
    3'b011 : begin
      if (i_RD == 2'sb11) 
        r_4B <= 4'b1100;
      else if (i_RD == 1'b1) 
        r_4B <= 4'b0011;
    end
    3'b100 : begin
      if (i_RD == 2'sb11) 
        r_4B <= 4'b1101;
      else if (i_RD == 1'b1) 
        r_4B <= 4'b0010;
    end
    3'b101 : r_4B <= 4'b1010;
    3'b110 : r_4B <= 4'b0110;
    3'b111 : begin
      if (i_RD == 2'sb11) 
        r_4B <= 4'b1110;
      else if (i_RD == 1'b1) 
        r_4B <= 4'b0001;
    end
  endcase
      
  
  	r_10B <= {r_6B, r_4B}; //r_10B fully created
    //calculate running disparity here
    if (r_10B[0] + r_10B[0] + r_10B[0] + r_10B[0] + r_10B[0] + r_10B[0] + r_10B[0] + r_10B[0] > 4)
      r_RD <= 2'sb11; //RD = -1
    else
      r_RD <= 2'sb01; //RD = 1 
  end
  
  always @(posedge i_Clk_Fast) begin
    r1_Data <= r_10B; //slow data in
    r2_Data <= r1_Data;
  end
    
  

  //assign o_Ser_Data = w_Byte_Data[0][2:0]; //[0] is the least significant bits
  assign o_Ser_Data = r_10B; 
  
endmodule

module Deserializer 
  (input i_Clk,
   input i_Clk_Fast,
   input [31:0] i_Data, 
   output [31:0] o_Des_Data);
  
  
  
endmodule

    
/*
    
   Count_And_Toggle #(.COUNT_LIMIT(CLKS_PER_SEC/4)) Count_Inst //divide by 4 so each lasts for 1/4 second
  (.i_Clk(i_Clk),
   .i_Enable(w_Count_En), //only want it counting during this phase of the game
   .o_Toggle(w_Toggle));
  
endmodule


module Count_And_Toggle #(COUNT_LIMIT = 10)
  (input i_Clk,
   input i_Enable,
   output reg o_Toggle);
  
  reg [$clog2(COUNT_LIMIT-1):0] r_Counter;
  
  always @(posedge i_Clk) begin
    if (i_Enable == 1'b1) begin
      if (r_Counter == COUNTER_LIMIT-1) begin
        o_Toggle <= !o_Toggle;
        r_Counter <= 0;
      end
      else
        r_Counter = r_Counter+1;
    end
    else
      o_Toggle <= 1'b0; //this is just a catch all to make sure not toggled on if not counting
  end
endmodule
*/
