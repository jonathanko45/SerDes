module synchronizer #(parameter WIDTH=3) 
  (input i_Clk,
   input i_Rst_n,
   input [WIDTH:0] i_d_in,
   output reg [WIDTH:0] o_d_out);
  
  reg [WIDTH:0] r_q1;
  
  always @(posedge i_Clk) begin
    if (!i_Rst_n) begin
      r_q1 <= 0;
      o_d_out <= 0;
    end else begin
      r_q1 <= i_d_in;
      o_d_out <= r_q1;
    end
  end
endmodule

