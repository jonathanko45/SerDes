`timescale 1ns / 1ps

interface serializer_if #(parameter DATA_WIDTH=8)
    (input clk,
     input clk_fast,
     input rst_n);
    
    logic ser_enable;
    logic [DATA_WIDTH-1:0] in_data;
    logic out_data;
    logic [9:0] out_10b;
endinterface: serializer_if

module serializer #(parameter DATA_WIDTH=8)
  (input i_Clk,
   input i_Clk_Fast,
   input i_rst_n, //need to implement this, set RD = -1, reset all xB values, change input to all zeroes
   input i_S_en,
   input [DATA_WIDTH-1:0] i_Data, 
   output o_Ser_Data,
   output reg [9:0] o_10B);

  reg signed [1:0] r_RD = 2'sb11; //RD = -1
  reg [3:0] r_4B = 0;
  reg [5:0] r_6B = 0;
  reg [9:0] r_10B = 0;
  
  reg r_Data_Ready = 1'b0;
  reg [DATA_WIDTH-1:0] r_Counter = 0;
  reg r1_Data = 1'b0; //2 registers for speeding up data
  reg r2_Data = 1'b0;
  
  always @(posedge i_Clk) begin //must be sequential since depends on previous value (RD)
    case (i_Data[4:0])
      5'b00000 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b100111;
        else if (r_RD == 2'sb01)
          r_6B <= 011000;
      end
      5'b00001 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b011101;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b100010;
      end  
      5'b00010 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b101101;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b010010;
      end
      5'b00011 : r_6B <= 6'b110001;
      5'b00100 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b110101;
        else if (r_RD == 2'sb01)
          r_6B <= 6'b001010;
      end
      5'b00101 : r_6B <= 6'b101001;
      5'b00110 : r_6B <= 6'b011001;
      5'b00111 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b111000;
        else if (r_RD == 2'sb01)
          r_6B <= 6'b000111;
      end
      5'b01000 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b111001;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b000110;
      end
      5'b01001 : r_6B <= 6'b100101;
      5'b01010 : r_6B <= 6'b010101;
      5'b01011 : r_6B <= 6'b110100;
      5'b01100 : r_6B <= 6'b001101;
      5'b01101 : r_6B <= 6'b101100;
      5'b01110 : r_6B <= 6'b011100;
      5'b01111 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b010111;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b101000;
      end
      5'b10000 : begin
        if (r_RD == 2'sb11) 
          r_6B <= 6'b011011;
        else if (r_RD == 2'sb01)
          r_6B <= 6'b100100;
      end
      5'b10001 : r_6B <= 6'b100011;
      5'b10010 : r_6B <= 6'b010011;
      5'b10011 : r_6B <= 6'b110010;
      5'b10100 : r_6B <= 6'b001011;
      5'b10101 : r_6B <= 6'b101010;
      5'b10110 : r_6B <= 6'b011010;
      5'b10111 : begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b111010;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b000101;
      end
      5'b11000 :begin
        if (r_RD == 2'sb11)
          r_6B <= 6'b110011;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b001100;
      end
      5'b11001 : r_6B <= 6'b100110;
      5'b11010 : r_6B <= 6'b010110;
      5'b11011 : begin
        if (r_RD == 2'sb11) 
          r_6B <= 6'b110110;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b001001;
      end
      5'b11100 : r_6B <= 6'b001110;
      5'b11101 : begin
        if (r_RD == 2'sb11) 
          r_6B <= 6'b101110;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b010001;
      end
      5'b11110 : begin
        if (r_RD == 2'sb11) 
          r_6B <= 6'b011110;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b100001;
      end
      5'b11111 : begin
        if (r_RD == 2'sb11) 
          r_6B <= 6'b101011;
        else if (r_RD == 2'sb01) 
          r_6B <= 6'b010100;
      end
      default : r_6B <= 6'b000000;
    endcase
    
    case (i_Data[7:5])
      3'b000 : begin
        if (r_RD == 2'sb11)
          r_4B <= 4'b1011;
        else if (r_RD == 2'sb01) 
          r_4B <= 4'b0100;
      end
      3'b001 : r_4B <= 4'b1001;
      3'b010 : r_4B <= 4'b0101;
      3'b011 : begin
        if (r_RD == 2'sb11) 
          r_4B <= 4'b1100;
        else if (r_RD == 2'sb01) 
          r_4B <= 4'b0011;
      end
      3'b100 : begin
        if (r_RD == 2'sb11) 
          r_4B <= 4'b1101;
        else if (r_RD == 2'sb01) 
          r_4B <= 4'b0010;
      end
      3'b101 : r_4B <= 4'b1010;
      3'b110 : r_4B <= 4'b0110;
      3'b111 : begin
        if (r_RD == 2'sb11) 
          r_4B <= 4'b1110;
        else if (r_RD == 2'sb01) 
          r_4B <= 4'b0001;
      end
      default : r_4B <= 4'b0000;
    endcase
  end
  
  //only activate when r_6B or r_4B update
  //should be combinational block
  always @(r_6B, r_4B) begin 
  	r_10B = {r_6B, r_4B}; //r_10B fully created
    //calculate running disparity here
    if (r_10B[0]+r_10B[1]+r_10B[2]+r_10B[3]+r_10B[4]+r_10B[5]+r_10B[6]+r_10B[7]+r_10B[8]+r_10B[9] > 5)
      r_RD = 2'sb01; //RD = +1 (more 1s then +1 RD)
    else if (r_10B[0]+r_10B[1]+r_10B[2]+r_10B[3]+r_10B[4]+r_10B[5]+r_10B[6]+r_10B[7]+r_10B[8]+r_10B[9] < 5)
      r_RD = 2'sb11; //RD = -1 (more 0s then -1 RD)
    r_Data_Ready = 1;
  end
  
  //need to send 1 bit of r_10B every clock cycle to output
  //here i need to be combining it with the clock, sending 1 bit per clock cycle
  always @(posedge i_Clk_Fast) begin
    if (r_Data_Ready) begin
      if (r_Counter == 11) begin //10 bits now + 2 cycles to make it through shift register
        r_Counter <= 0;
        r_Data_Ready <= 0;
      end
      else if (r_Counter <= 9) begin //so we dont access beyond array length
        r_Counter <= r_Counter + 1;
        r1_Data <= r_10B[r_Counter]; //slow data in 
        r2_Data <= r1_Data;
      end
      else begin //continues to shift data after all has been moved into shift register
        r_Counter <= r_Counter + 1;
        r2_Data <= r1_Data;
      end
    end
  end
  
  assign o_10B = r_10B;
  assign o_Ser_Data = r2_Data; 
endmodule

