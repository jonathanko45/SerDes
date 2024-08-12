module SerDes_Project_TB();
  
  parameter DATA_WIDTH = 8;
  
  //for Serializer
  reg r_Clk = 1'b0, r_Clk_Fast = 1'b0;
  reg [DATA_WIDTH-1:0] r_Data;
  wire w_Ser_Data;
  wire [9:0] w_10B;
  
  Serializer seUUT
  (.i_Clk(r_Clk),
   .i_Clk_Fast(r_Clk_Fast),
   .i_Data(r_Data),
   .o_Ser_Data(w_Ser_Data),
   .o_10B(w_10B));
  
  //for Deserializer
  reg r_W_en, r_Wrst_n;
  reg r_R_en, r_Rrst_n;
  reg r_Ser_Data; //same as r_Data_In
  wire [7:0] w_Des_Out;
  wire w_FIFO_Out;
  //wire w_Des_Out;
  wire w_full, w_empty;

  // Queue to push data_in (not synthesizable, only for simulation) 
  reg r_Wdata_q[$]; //FIFO queue
  reg r_Wdata = 0;
  reg r_Ser_Data_q[$]; //serialized data queue
  
  Deserializer deUUT
  (.i_Rclk(r_Clk),
   .i_Wclk(r_Clk_Fast),
   .i_Wrst_n(r_Wrst_n),
   .i_Rrst_n(r_Rrst_n),
   .i_W_en(r_W_en),
   .i_R_en(r_R_en),
   .i_Data_In(r_Ser_Data),
   .o_Data_Out(w_Des_Out),
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
    
    repeat(10) @(posedge r_Clk_Fast); //waits 10 clock cycles, alternative to #10 time
    r_Wrst_n = 1'b1;
    
    repeat (2) begin //idk??
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
    #10;
    $display("Sending 8b: %b", r_Data);
    $display("5b %b", r_Data[4:0]);
    $display("3b %b", r_Data[7:5]);
    #41;
    $display("10b encoded: %b", w_10B);
    #39; //simulated transmission delay over high speed medium
    

    repeat(10) @(posedge r_Clk);
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
    
    repeat(5) @(posedge r_Clk);
    $display("5b %b", w_Des_Out[4:0]);
    $display("3b %b", w_Des_Out[7:5]);
    $display("TIME = %0t: 8b decoded: %b", $time, w_Des_Out);
    
    $finish();
  end
  
  
  //reset r_Counter if want to use again
  always @(posedge r_Clk_Fast) begin //takes 2 cycles to become stable
    if(r_Clk && r_Counter-2 >= 0 && r_Counter-2 <= 9) begin
      $display ("Time = %0t: SERIALISED [%0d]: %b", $time, r_Counter-2, w_Ser_Data);
      r_Ser_Data_q.push_back(w_Ser_Data); //add value to a queue variable, to be used later in FIFO
      r_Counter <= r_Counter + 1;
    end
    else if(r_Clk && r_Counter <= 11)
      r_Counter <= r_Counter + 1;
  end
  
endmodule
