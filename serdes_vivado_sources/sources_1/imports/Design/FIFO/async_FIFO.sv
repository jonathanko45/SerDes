module async_FIFO #(parameter DEPTH=8, parameter PTR_WIDTH = $clog2(DEPTH))
  (input i_Wclk, i_Wrst_n, i_W_en,
   input i_Rclk, i_Rrst_n, i_R_en,
   input i_Data_In,
   output reg o_Data_Out,
   output reg o_full, o_empty);
  
  reg [PTR_WIDTH:0] r_g_wptr_sync, r_g_rptr_sync;
  reg [PTR_WIDTH:0] r_b_wptr, r_b_rptr;
  reg [PTR_WIDTH:0] r_g_wptr, r_g_rptr;
  
  ///write pointer to read clock domain
  synchronizer #(PTR_WIDTH) sync_wptr (
    .i_Clk(i_Rclk), 
    .i_Rst_n(i_Rrst_n), 
    .i_d_in(r_g_wptr), 
    .o_d_out(r_g_wptr_sync));
  
  //read pointer to write clock domain
  synchronizer #(PTR_WIDTH) sync_rptr (
    .i_Clk(i_Wclk), 
    .i_Rst_n(i_Wrst_n), 
    .i_d_in(r_g_rptr), 
    .o_d_out(r_g_rptr_sync));
  
  wptr_handler #(PTR_WIDTH) wptr_h (
    .i_Wclk(i_Wclk), 
    .i_Wrst_n(i_Wrst_n), 
    .i_W_en(i_W_en), 
    .i_g_rptr_sync(r_g_rptr_sync), 
    .o_b_wptr(r_b_wptr), 
    .o_g_wptr(r_g_wptr), 
    .o_full(o_full));
  
  rptr_handler #(PTR_WIDTH) rptr_h (
    .i_Rclk(i_Rclk), 
    .i_Rrst_n(i_Rrst_n), 
    .i_R_en(i_R_en), 
    .i_g_wptr_sync(r_g_wptr_sync), 
    .o_b_rptr(r_b_rptr), 
    .o_g_rptr(r_g_rptr), 
    .o_empty(o_empty));
  
  FIFO_memory FIFOm (
    .i_Wclk(i_Wclk), 
    .i_Wrst_n(i_Wrst_n), 
    .i_W_en(i_W_en), 
    .i_Rclk(i_Rclk), 
    .i_R_en(i_R_en), 
    .i_b_wptr(r_b_wptr), 
    .i_b_rptr(r_b_rptr), 
    .i_Data_In(i_Data_In), 
    .i_full(o_full), 
    .i_empty(o_empty), 
    .o_Data_Out(o_Data_Out));
    
endmodule