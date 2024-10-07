module wptr_handler #(parameter PTR_WIDTH=3)
  (input i_Wclk, i_Wrst_n, i_W_en,
   input [PTR_WIDTH:0] i_g_rptr_sync,
   output reg [PTR_WIDTH:0] o_b_wptr, o_g_wptr,
   output reg o_full);
  
  reg [PTR_WIDTH:0] r_b_wptr_next;
  reg [PTR_WIDTH:0] r_g_wptr_next;
  wire w_wfull;
  
  //this incriments if write enabled and not full
  assign r_b_wptr_next = o_b_wptr+(i_W_en & !o_full); 
  //this converts binary to gray code (eg binary 2 = 0010 -> gray 2 = 0011)
  assign r_g_wptr_next = (r_b_wptr_next >> 1)^r_b_wptr_next;
  
  always @(posedge i_Wclk or negedge i_Wrst_n) begin
    if (!i_Wrst_n) begin
      o_b_wptr <= 0;
      o_g_wptr <= 0;
    end else begin
      o_b_wptr <= r_b_wptr_next; //incr binary write pointer
      o_g_wptr <= r_g_wptr_next; //incr gray write pointer
    end
  end
  
  always @(posedge i_Wclk or negedge i_Wrst_n) begin
    if (!i_Wrst_n) begin
      o_full <= 0;
    end else begin
      o_full <= w_wfull;
    end
  end
  
  //this determines if it is full based on if the next ptr is out of bounds
  //is full when the write ptr next is same as read ptr sync
  assign w_wfull = (r_g_wptr_next == {~i_g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], i_g_rptr_sync[PTR_WIDTH-2:0]});
endmodule