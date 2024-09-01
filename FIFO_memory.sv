module FIFO_memory #(parameter DEPTH=8, PTR_WIDTH=3)
  (input i_Wclk, i_Wrst_n, i_W_en, i_Rclk, i_R_en,
   input [PTR_WIDTH:0] i_b_wptr, i_b_rptr,
   input i_Data_In,
   input i_full, i_empty,
   output reg o_Data_Out);
  
  reg r_FIFO [0:DEPTH-1];
  
  always @(posedge i_Wclk) begin
    if (!i_Wrst_n) 
      r_FIFO[i_b_wptr[PTR_WIDTH-1:0]] <= 0;
    else if (i_W_en & !i_full)
      r_FIFO[i_b_wptr[PTR_WIDTH-1:0]] <= i_Data_In;
  end
  
  assign o_Data_Out = r_FIFO[i_b_rptr[PTR_WIDTH-1:0]];

endmodule
