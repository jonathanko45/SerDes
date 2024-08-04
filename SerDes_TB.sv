/*
time scale: https://www.chipverify.com/verilog/verilog-timescale

send a ton of data all at once.
eg send  01011101  all at once (8 bits)

the serializer will then take this and split it up, sending it with the clock

start with a runnin disparity (RD) of -1
pass in the DEPTH as well relative to the size of the text

if we want 1Gigabit/sec 
with bus width of 1 (sending bits 1 at a time) need 1024 MHz to get 1 GB/s

lets do 
slow = 20 MHz 
fast = 1000 MHz
*/

/* CURRENT STEPS
Serializer
2. add resets



Deserializer
1. make FIFO https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
2. edit FIFO to have almost full and change to use that (maybe)
3. serial to parallel convert (slow clock does this)
4. decode the data 
5. output to TB

*/

module SerDes_Project_TB();
  
  parameter DATA_WIDTH = 8;
  
  //for Serializer
  reg r_Clk, r_Clk_Fast;
  reg [DATA_WIDTH-1:0] r_Data;
  reg signed [1:0] r_RD = 2'sb11; //RD = -1
  wire [DATA_WIDTH-1:0] w_Ser_Data;
  
  Serializer seUUT
  (.i_Clk(r_Clk),
   .i_Clk_Fast(r_Clk_Fast),
   .i_Data(r_Data),
   .i_RD(r_RD),
   .o_Ser_Data(w_Ser_Data));
  
  //for Deserializer
  reg r_W_en, r_Wrst_n;
  reg r_R_en, r_Rrst_n;
  reg [DATA_WIDTH-1:0] r_Data_In;
  wire [DATA_WIDTH-1:0] w_Data_Out;
  wire w_full, w_empty;

  // Queue to push data_in (not synthesizable, only for simulation)
  reg [DATA_WIDTH-1:0] r_Wdata_q[$], r_Wdata;
  
  Deserializer deUUT
  (.i_Rclk(r_Clk),
   .i_Wclk(r_Clk_Fast),
   .i_Wrst_n(r_Wrst_n),
   .i_Rrst_n(r_Rrst_n),
   .i_W_en(r_W_en),
   .i_R_en(r_R_en),
   .i_Data_In(r_Data_In),
   .o_Data_Out(w_Data_Out),
   .o_full(w_full),
   .o_empty(w_empty));
   
  always #50ns r_Clk = ~r_Clk; //20MHz read
  always #1ns r_Clk_Fast = ~r_Clk_Fast; //1000MHz write
  
  /*
  initial begin //fast (write) clock
    r_Clk_Fast = 1'b0;
    r_Wrst_n = 1'b0;
    r_W_en = 1'b0;
    r_Data_In = 0;
    
   
    repeat(10) @(posedge r_Clk_Fast);
    r_Wrst_n = 1'b1;
    
    repeat (2) begin
      for (int i=0; i<30; i++) begin
        @(posedge r_Clk_Fast iff !w_full); //if and only iff !w_full
        r_W_en = (i%2 == 0)? 1'b1 : 1'b0; //alternates?
        if(r_W_en) begin
          r_Data_In = $urandom; //randomizer
          r_Wdata_q.push_back(r_Data_In);
        end
      end
      #50;
    end
  end
  */
  
  
  initial begin //slow read clock
    $dumpfile("dump.vcd");
    $dumpvars;
    
    /*
    r_Clk = 1'b0;
    r_Rrst_n = 1'b0;
    r_R_en = 1'b0;
    
    repeat(20) @(posedge r_Clk);
    r_Rrst_n = 1'b1;
    
    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge r_Clk iff !w_empty);
        r_R_en = (i%2 == 0)? 1'b1 : 1'b0;
        if(r_R_en) begin
          r_Wdata = r_Wdata_q.pop_front();
          if (w_Data_Out !== r_Wdata) 
            $error ("Time = %0t: Comparison FAILED: expected wr_data = %h, rd_data = %h", $time, r_Wdata, w_Data_Out);
          else
            $display ("Time = %0t: Comparison PASSED: wr_data = %h, rd_data = %h", $time, r_Wdata, w_Data_Out);
        end
      end
      #50;
    end
    */
      
    
    
    //r_Data <= 32'b11001001010101011010001101011101;
    r_Data <= 8'b01011101;
    #10;
    $display("Sending: %b", r_Data);
    $display("8b %b", r_Data[7:0]);
    $display("5b %b", r_Data[4:0]);
    $display("3b %b", r_Data[7:5]);
    $display("%d", r_RD);
    
    //if (w_Ser_Data == r_Data[7:0]) 
    $display ("TEST  ##### %b", w_Ser_Data);
    
    

    $finish();
  end
  
endmodule
