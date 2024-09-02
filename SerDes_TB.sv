`timescale 1ns / 1ps

module SerDes_TB();
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
  
  SerDes_Top UUT 
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
  
  reg [3:0] r_Counter = 0;
  reg r_Input_En = 0;
  
  initial begin //fast (write) clock
  	r_Clk_Fast = 1'b0;
    r_Wrst_n = 1'b0;
    r_W_en = 1'b0;
    r_Data = 0;
    r_Ser_Data = 0;
    
    #380; //simulated delay
    
    r_Wrst_n = 1'b1;
    repeat (4) begin
      for (int i=0; i<20; i++) begin
        @(posedge r_Clk_Fast iff !w_full); //if and only not full
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
    
    #10;
    $display("");
    $display("\///// BEGINNING TRANSMISSION /////");
    $display("");
    
    //sending data block
    r_Input_En <= 1'b1;
    
    r_Data <= 8'b01011101;
    @(posedge r_Clk); #30;
    r_Data <= 8'b10100111;
    @(posedge r_Clk); #30;
    r_Data <= 8'b11100001;
    @(posedge r_Clk); #30;
    r_Data <= 8'b00100111;
    @(posedge r_Clk); #30;

    r_Input_En <= 1'b0;
    //sending data block end
    
    $display("");
    $display("\///// TRANSMISSION FINISHED, STARTING RECEIVING /////");
    $display("");
    
    r_Rrst_n = 1'b1;
    repeat(4) begin
      for (int i=0; i<20; i++) begin
        @(posedge r_Clk iff !w_empty); //if and only if not empty
        r_R_en = (i%2 == 0)? 1'b1 : 1'b0;
        if(r_R_en) begin
          r_Wdata = r_Wdata_q.pop_front();
          if (w_FIFO_Out !== r_Wdata)
            $display ("Time = %0t: Comparison FAILED: expected wr_data = %h, rd_data = %h", $time, r_Wdata, w_FIFO_Out);
          else
            $display ("Time = %0t: Comparison PASSED: wr_data = %h, rd_data = %h", $time, r_Wdata, w_FIFO_Out);
        end 
      end
      #50;
      $display("Time = %0t: DECODED 8b: %b (%b)(%b)",$time, w_Des_Out, w_Des_Out[4:0], w_Des_Out[7:5]);
    end
    
    $display("");
    $display("\///// RECEIVING FINISHED /////");
    $display("");
    $finish();
  end
  
  always @(r_Data) begin
    $display("Time = %0t: SENDING 8b: %b (%b)(%b)",$time, r_Data, r_Data[7:5], r_Data[4:0]);
  end
  
  always @(w_10B) begin
    $display("Time = %0t: 10b encoded: %b (%b)(%b)",$time, w_10B, w_10B[9:4], w_10B[3:0]);
  end
  
  //reset r_Counter if want to use again
  //or since this is just a TB, increase the number of bytes (ie 8 -> 16/32)
  always @(posedge r_Clk_Fast) begin //takes 2 cycles to become stable
    if (r_Input_En) begin
      if(r_Clk && r_Counter >= 2 && r_Counter <= 11) begin //<= 11
        $display ("Time = %0t: SERIALISED [%0d]: %b", $time, r_Counter-2, w_Ser_Data);
        r_Ser_Data_q.push_back(w_Ser_Data); //add value to a queue variable, to be used later in FIFO
        r_Counter <= r_Counter + 1;
      end
      else if(r_Clk && r_Counter <= 11) //<= 11 for first 2 clk
        r_Counter <= r_Counter + 1;
      else if(r_Counter > 11) begin
        if (!r_Clk)
          r_Counter <= 0;
      end
    end
  end
endmodule

