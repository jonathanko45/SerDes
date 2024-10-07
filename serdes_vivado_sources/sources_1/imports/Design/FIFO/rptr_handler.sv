module rptr_handler #(parameter PTR_WIDTH=3) 
  (input i_Rclk, i_Rrst_n, i_R_en,
   input [PTR_WIDTH:0] i_g_wptr_sync,
   output reg [PTR_WIDTH:0] o_b_rptr, o_g_rptr,
   output reg o_empty, o_rempty);
  
  reg [PTR_WIDTH:0] r_b_rptr_next;
  reg [PTR_WIDTH:0] r_g_rptr_next;
  
  assign r_b_rptr_next = o_b_rptr + (i_R_en & !o_empty); 
  assign r_g_rptr_next = (r_b_rptr_next >> 1)^r_b_rptr_next;
  assign o_rempty = (i_g_wptr_sync == r_g_rptr_next);
  
  always @(posedge i_Rclk or negedge i_Rrst_n) begin
    if (!i_Rrst_n) begin
      o_b_rptr <= 0;
      o_g_rptr <= 0;
    end else begin
      o_b_rptr <= r_b_rptr_next;
      o_g_rptr <= r_g_rptr_next;
    end
  end
  
  always @(posedge i_Rclk or negedge i_Rrst_n) begin
    if (!i_Rrst_n) begin
      o_empty <= 1;
    end else begin
      o_empty <= o_rempty;
    end
  end
endmodule