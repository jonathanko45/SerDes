module SerDes #(parameter DATA_WIDTH=8)
  (input i_Clk, i_S_en,
   input i_Clk_Fast,
   input [DATA_WIDTH-1:0] i_Data,
   output o_Ser_Data,
   output reg [9:0] o_10B,
   
   input i_Wrst_n, i_W_en,
   input i_Rrst_n, i_R_en,
   input i_Data_In,
   output reg [7:0] o_Data,
   output reg o_FIFO_Out,
   output reg o_full, o_empty
  );
  
  Serializer Ser (
    .i_Clk(i_Clk),
    .i_S_en(i_S_en),
    .i_Clk_Fast(i_Clk_Fast),
    .i_Data(i_Data),
    .o_Ser_Data(o_Ser_Data),
    .o_10B(o_10B)
  	);
  
  Deserializer Des (
    .i_Wclk(i_Clk_Fast),    
    .i_Wrst_n(i_Wrst_n), 
    .i_W_en(i_W_en), 
    .i_Rclk(i_Clk), 
    .i_Rrst_n(i_Rrst_n), 
    .i_R_en(i_R_en), 
    .i_Data_In(i_Data_In), 
    .o_Data(o_Data),
    .o_FIFO_Out(o_FIFO_Out),
    .o_full(o_full), 
    .o_empty(o_empty)
  	);
  
endmodule


module Serializer #(parameter DATA_WIDTH=8)
  (input i_Clk,
   input i_Clk_Fast,
   input i_S_en,
   input [DATA_WIDTH-1:0] i_Data, 
   output o_Ser_Data,
   output reg [9:0] o_10B);

  reg signed [1:0] r_RD = 2'sb11; //RD = -1
  reg [3:0] r_4B = 4'b000;
  reg [5:0] r_6B = 6'b00000;
  reg [9:0] r_10B = 10'b0000000000;
  
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



module Deserializer #(parameter DEPTH=8, DATA_WIDTH=10)
  (input i_Wclk, i_Wrst_n, i_W_en,
   input i_Rclk, i_Rrst_n, i_R_en,
   input i_Data_In,
   output reg [7:0] o_Data,
   output reg o_FIFO_Out,
   output reg o_full, o_empty);
 
  reg [DATA_WIDTH-1:0] r_Des_Data = 10'b0000000000;
  reg [DATA_WIDTH-1:0] r_Counter = 0;
  
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
        r_Des_Data[DATA_WIDTH-1] <= o_FIFO_Out; //put it in reverse order from recieved
        r_Des_Data[DATA_WIDTH-2:0] <= r_Des_Data[DATA_WIDTH-1:1];
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
  assign o_Data_Out = r_8B;
  
endmodule
