/*
time scale: https://www.chipverify.com/verilog/verilog-timescale

send a ton of data all at once.
send the data as decimal (convert it here, or don't)
eg send 11001001 01010101 10100011 01011101  all at once (32 bit)
32'b11001001010101011010001101011101

the serializer will then take this and split it up, sending it with the clock

start with a runnin disparity (RD) of -1
pass in the DEPTH as well relative to the size of the text

if we want 1Gigabit/sec 
with bus width of 1 (sending bits 1 at a time) need 1024 MHz to get 1 GB/s
*/

/* CURRENT STEPS
1. figure out how to split string into bytes
	https://www.chipverify.com/systemverilog/systemverilog-packed-arrays
2. figure out how the scheme works for numbers like 11111
	need to use case statements for the 'lookup table'
3. figure out how to get the disparity (sum the digits?)
4. do the disparity change
5. figure out how to reassemble into serialized value (should be easy)
6. do 3b/4b scheme case statement
7. RD needs to be done properly (not twice with both 5b and 3b)


8. make clock speed
9. use 2 flip-flops to speed up to faster clock domain
10. send to output
Serializer done

Deserializer
1. make FIFO https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
2. 

*/

module SerDes_Project_TB();
  reg r_Clk;
  reg [31:0] r_Data;
  reg signed [1:0] r_RD = 2'sb11; //RD = -1
  wire [31:0] w_Ser_Data;
  
  
  SerDes_Project UUT
  (.i_Clk(r_Clk),
   .i_Data(r_Data),
   .i_RD(r_RD),
   .o_Ser_Data(w_Ser_Data)
  );
  
  always #1 r_Clk <= !r_Clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    r_Data <= 32'b11001001010101011010001101011101;
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
