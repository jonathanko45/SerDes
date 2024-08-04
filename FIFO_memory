module FIFO_memory #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3)
  (input i_Wclk, i_W_en, i_Rclk, i_R_en,
   input [PTR_WIDTH:0] i_b_wptr, i_b_rptr,
   input [DATA_WIDTH-1:0] i_Data_In,
   input i_full, i_empty,
   output reg [DATA_WIDTH-1:0] o_Data_Out);
  
  reg [DATA_WIDTH-1:0] r_FIFO [0:DEPTH-1];
  
  always @(posedge i_Wclk) begin
    if (i_W_en & !i_full)
      r_FIFO[i_b_wptr[PTR_WIDTH-1:0]] <= i_Data_In;
  end
  
  /*
  always @(posedge i_Rclk) begin
    if (r_R_en & !i_empty)
      o_Data_Out <= r_FIFO[i_b_rptr[PTR_WIDTH-1:0]];
  end*/
  
  assign o_Data_Out = r_FIFO[i_b_rptr[PTR_WIDTH-1:0]];

endmodule
