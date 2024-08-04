module async_FIFO #(parameter DEPTH=8, DATA_WIDTH=8)
  (input i_Wclk, i_Wrst_n, i_W_en,
   input i_Rclk, i_Rrst_n, i_R_en,
   input [DATA_WIDTH-1:0] i_Data_In,
   output reg [DATA_WIDTH-1:0] o_Data_Out,
   output reg o_full, o_empty);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
  
  reg [PTR_WIDTH:0] r_g_wptr_sync, r_g_rptr_sync;
  reg [PTR_WIDTH:0] r_b_wptr, r_b_rptr;
  reg [PTR_WIDTH:0] r_g_wptr, r_g_rptr;
  
  wire [PTR_WIDTH-1:0] w_Waddr, w_Raddr;
  
  ///write pointer to read clock domain
  synchronizer #(PTR_WIDTH) sync_wptr(i_Rclk, i_Rrst_n, r_g_wptr, r_g_wptr_sync);
  //read pointer to write clock domain
  synchronizer #(PTR_WIDTH) sync_rptr(i_Wclk, i_Wrst_n, r_g_rptr, r_g_rptr_sync);
  
  wptr_handler #(PTR_WIDTH) wptr_h(i_Wclk, i_Wrst_n, i_W_en, r_g_rptr_sync, r_g_wptr, o_full);
  rptr_handler #(PTR_WIDTH) rptr_h(i_Rclk, i_Rrst_n, i_R_en, r_g_wptr_sync, r_g_rptr, o_empty);
  
  FIFO_memory FIFOm (i_Wclk, i_W_en, i_Rclk, i_R_en, r_b_wptr, r_b_rptr, i_Data_In, o_full, o_empty, o_Data_Out);
endmodule
