
/* CURRENT STEPS
compare the new bits to the tables, figure out how Ser is working before moving onto Des

should be ready to take unlimited input, just testbench that needs to show it
GOAL: send 32 bits of data (can be random)

   4         3       2        1
00100111 11100001 10100111 01011101

1. get multiple data input working (utilizing RD)
4. ^ increase depth of FIFO. dont think i actually need this?

4. add resets instead of initializing at 0
6. change formatting of all modules to be consistent
7. account for special cases (RD)

0. transfer over to Vivado and implement hardware PLL/CDR
0. ^ figure out how to export from Vivado to GitHub
*/

module SerDes_Project_TB();
  
  //for Serializer
  reg r_Clk = 1'b0, r_Clk_Fast = 1'b0;
  reg r_S_en = 1'b0;
  reg [7:0] r_Data;
  wire w_Ser_Data;
  wire [9:0] w_10B;
  
  //for Deserializer
  reg r_W_en, r_Wrst_n;
  reg r_R_en, r_Rrst_n;
  reg r_Ser_Data; //same as r_Data_In
  wire [7:0] w_Des_Out;
  wire w_FIFO_Out;
  wire w_full, w_empty;

  // Queue to push data_in (not synthesizable, only for simulation) 
  reg r_Wdata_q[$]; //FIFO queue
  reg r_Wdata = 0;
  reg r_Ser_Data_q[$]; //serialized data queue
  
  SerDes UUT 
  (.i_Clk(r_Clk),
   .i_S_en(r_S_en),
   .i_Clk_Fast(r_Clk_Fast),
   .i_Data(r_Data),
   .o_Ser_Data(w_Ser_Data),
   .o_10B(w_10B),
   
   .i_Wrst_n(r_Wrst_n),
   .i_Rrst_n(r_Rrst_n),
   .i_W_en(r_W_en),
   .i_R_en(r_R_en),
   .i_Data_In(r_Ser_Data),
   .o_Data(w_Des_Out),
   .o_FIFO_Out(w_FIFO_Out),
   .o_full(w_full),
   .o_empty(w_empty));
  
  
  always #50ns r_Clk = ~r_Clk; //20MHz read
  always #1ns r_Clk_Fast = ~r_Clk_Fast; //1000MHz write
  
  reg [9:0] r_Counter = 0;
  
  initial begin //fast (write) clock
  	r_Clk_Fast = 1'b0;
    r_Wrst_n = 1'b0;
    r_W_en = 1'b0;
    r_Ser_Data = 0;
    #61;

    r_Wrst_n = 1'b1;
    
    repeat (2) begin
      for (int i=0; i<10; i++) begin
        @(posedge r_Clk_Fast iff !w_full); //if and only iff !w_full
        r_W_en = (i%2 == 0)? 1'b1 : 1'b0;
        if(r_W_en) begin
          r_Ser_Data = r_Ser_Data_q.pop_front(); //r_Ser_Data = r_Data_In, essentailly sending it
          r_Wdata_q.push_back(r_Ser_Data);
        end
      end
      #50;
    end
  end

  initial begin //slow read clock
    $dumpfile("dump.vcd");
    $dumpvars;
     
    r_Clk = 1'b0;
    r_Rrst_n = 1'b0;
    r_R_en = 1'b0;
    
    r_Data <= 8'b01011101;
    /*
    @(posedge r_Clk);
    r_Data <= 8'b10100111;
    @(posedge r_Clk);
    r_Data <= 8'b00100111;
    @(posedge r_Clk);
    r_Data <= 8'b11100001;*/
    
    #90; //simulated transmission delay over high speed medium, beter to repreat clk cycles
    
    r_Rrst_n = 1'b1;
    
    repeat(2) begin
      for (int i=0; i<10; i++) begin
        @(posedge r_Clk iff !w_empty);
        r_R_en = (i%2 == 0)? 1'b1 : 1'b0;
        if(r_R_en) begin
          r_Wdata = r_Wdata_q.pop_front();
          if (w_FIFO_Out !== r_Wdata)
            $error ("Time = %0t: Comparison FAILED: expected wr_data = %h, rd_data = %h", $time, r_Wdata, w_FIFO_Out);
          else
            $display ("Time = %0t: Comparison PASSED: wr_data = %h, rd_data = %h", $time, r_Wdata, w_FIFO_Out);
        end
      end
      #50;
    end
    
    #100;
    $display("Time = %0t: 5b %b",$time, w_Des_Out[4:0]);
    $display("Time = %0t: 3b %b",$time, w_Des_Out[7:5]);
    $display("TIME = %0t: decoded 8b: %b", $time, w_Des_Out);
    $finish();
  end
  
  always @(r_Data) begin
    $display("Time = %0t: SENDING 8b: %b (%b)(%b)",$time, r_Data, r_Data[4:0], r_Data[7:5]);
    #10;
    $display("Time = %0t: 10b encoded: %b (%b)(%b)",$time, w_10B, w_10B[9:4], w_10B[3:0]);
  end
  
  //reset r_Counter if want to use again
  //or since this is just a TB, increase the number of bytes (ie 8 -> 16/32)
  always @(posedge r_Clk_Fast) begin //takes 2 cycles to become stable
    if(r_Clk && r_Counter-2 >= 0 && r_Counter-2 <= 9) begin //<= 9
      $display ("Time = %0t: SERIALISED [%0d]: %b", $time, r_Counter-2, w_Ser_Data);
      r_Ser_Data_q.push_back(w_Ser_Data); //add value to a queue variable, to be used later in FIFO
      r_Counter <= r_Counter + 1;
    end
    else if(r_Clk && r_Counter <= 11) //<= 11
      r_Counter <= r_Counter + 1;
  end
endmodule
