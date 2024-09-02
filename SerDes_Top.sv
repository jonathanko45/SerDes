`timescale 1ns / 1ps

`include "Serializer.sv"
`include "Deserializer.sv"
`include "synchronizer.sv"
`include "wptr_handler.sv"
`include "rptr_handler.sv"
`include "FIFO_memory.sv"
`include "async_FIFO.sv"

module SerDes_Top #(parameter DATA_WIDTH=8)
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