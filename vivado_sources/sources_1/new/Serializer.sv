`timescale 1ns / 1ps

interface serializer_if #(parameter DATA_WIDTH=8)
    (input clk,
     input clk_fast,
     input reset);
    
    logic [DATA_WIDTH-1:0] in_data;
    logic signed in_RD;
    logic rst_n;
    logic out_data;
    logic [9:0] out_10b;
    logic signed [1:0] out_RD;
    
    //for driver
    clocking dr_cb@(posedge clk);
        output in_data;
        output in_RD;
        output rst_n;
        input out_10b;
        input out_RD;
    endclocking
    modport DRV (clocking dr_cb, input clk, reset);
    
    //for monitor
    clocking rc_cb@(negedge clk);
        input in_data;
        input in_RD;
        input rst_n;
        input out_10b;
        input out_RD;
    endclocking
    modport RCV (clocking rc_cb, input clk, reset);
    
    //montior fast output
    clocking rc_cb_fast@(posedge clk_fast);
        input out_data;
    endclocking
    modport RCV_fast (clocking rc_cb_fast, input clk_fast, reset);
    
endinterface: serializer_if

module serializer #(parameter DATA_WIDTH=8)
  (input i_Clk,
   input i_Clk_Fast,
   input i_rst_n,
   input [DATA_WIDTH-1:0] i_Data, 
   input signed [1:0] i_RD,
   output o_Ser_Data,
   output reg [9:0] o_10B,
   output reg signed [1:0] o_RD);

  reg signed [1:0] r_RD = i_RD; //RD = 2'sb11 =-1
  reg [3:0] r_4B;
  reg [5:0] r_6B;
  reg [9:0] r_10B;
  
  reg [2:0] r_Data_Stage;
  reg [DATA_WIDTH-1:0] r_Counter;
  reg r1_Data; //2 registers for speeding up data
  reg r2_Data;
  
  always @(posedge i_Clk) begin //must be sequential since depends on previous value (RD)
    if (!i_rst_n) begin
      r_4B <= 0;
      r_6B <= 0;
      r_10B <= 0;
      r_RD <= 2'sb11; //RD = -1
      r_Data_Stage <= 3'b000;
    end else begin 
      if (r_Data_Stage == 3'b000) begin
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
        r_Data_Stage <= 3'b001;
      end else if (r_Data_Stage == 3'b001) begin
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
        r_Data_Stage <= 3'b010;
      end
    end
  end
  
  //should be combinational block
  always @(r_Data_Stage) begin
    if (r_Data_Stage == 3'b001) begin
        if (r_6B[0]+r_6B[1]+r_6B[2]+r_6B[3]+r_6B[4]+r_6B[5] > 3)
          r_RD = 2'sb01; //RD = +1 (more 1s then +1 RD)
        else if (r_6B[0]+r_6B[1]+r_6B[2]+r_6B[3]+r_6B[4]+r_6B[5] < 3)
          r_RD = 2'sb11; //RD = -1 (more 0s then -1 RD)
    end else if (r_Data_Stage == 3'b010) begin
        r_10B = {r_6B, r_4B}; //r_10B fully created
        //calculate running disparity here
        if (r_10B[0]+r_10B[1]+r_10B[2]+r_10B[3]+r_10B[4]+r_10B[5]+r_10B[6]+r_10B[7]+r_10B[8]+r_10B[9] > 5)
          r_RD = 2'sb01; //RD = +1 (more 1s then +1 RD)
        else if (r_10B[0]+r_10B[1]+r_10B[2]+r_10B[3]+r_10B[4]+r_10B[5]+r_10B[6]+r_10B[7]+r_10B[8]+r_10B[9] < 5)
          r_RD = 2'sb11; //RD = -1 (more 0s then -1 RD)
        r_Data_Stage = 3'b011;
    end
  end
  
  //need to send 1 bit of r_10B every clock cycle to output
  //here i need to be combining it with the clock, sending 1 bit per clock cycle
  always @(posedge i_Clk_Fast) begin
    if (!i_rst_n) begin
       r1_Data <= 0;
       r2_Data <= 0;
       r_Counter <= 0;
     end else begin
        if (r_Data_Stage == 3'b011) begin
          if (r_Counter == 11) begin //10 bits now + 2 cycles to make it through shift register
            r_Counter <= 0; 
            r_Data_Stage <= 3'b000;
          end
          else if (r_Counter <= 9) begin //so we dont access beyond array length
            r_Counter <= r_Counter + 1;
            r1_Data <= r_10B[r_Counter]; //slow data in, LSB first
            r2_Data <= r1_Data;
          end
          else begin //continues to shift data after all has been moved into shift register
            r_Counter <= r_Counter + 1;
            r2_Data <= r1_Data;
          end
        end
     end
  end
  
  assign o_10B = r_10B;
  assign o_Ser_Data = r2_Data; 
  assign o_RD = r_RD;
  
endmodule

