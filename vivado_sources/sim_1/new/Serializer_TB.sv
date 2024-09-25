`ifndef SERIALIZER_TB
`define SERIALIZER_TB

 `include "uvm_macros.svh"
import uvm_pkg::*;

module Serializer_TB;
   
   import ser_test_lib::*;
    
    bit clk;
    bit clk_fast;
    bit rst_n;
    
    serializer_if ser_intf (.clk(clk),
                            .clk_fast(clk_fast),
                            .rst_n(rst_n));
                         
    serializer ser_top (.i_Clk(clk),
                        .i_Clk_Fast(clk_fast),
                        .i_S_en(ser_intf.ser_enable), //currently does nothing? remove
                        .i_Data(ser_intf.in_data),
                        .o_Ser_Data(ser_intf.out_data),
                        .o_10B(ser_intf.out_10b));
    
    always #50ns clk = ~clk; //20MHz read
    always #1ns clk_fast = ~clk_fast; //1000MHz write
    
    initial begin
        #5 rst_n = 1'b0;
        #25 rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual serializer_if)::set(uvm_root::get(), "*", "intf", ser_intf);
        run_test();
    end
    
endmodule

`endif
