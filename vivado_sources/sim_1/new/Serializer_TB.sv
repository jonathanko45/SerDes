`ifndef SERIALIZER_TB
`define SERIALIZER_TB

 `include "uvm_macros.svh"
import uvm_pkg::*;

module Serializer_TB;
   
   import ser_test_lib::*;
    
    bit clk;
    bit clk_fast;
    bit rst_n;
    
    serializer_if i_vif (.clk(clk),
                         .clk_fast(clk_fast),
                         .rst_n(rst_n));
        
    serializer_if o_vif (.clk(clk),
                         .clk_fast(clk_fast),
                         .rst_n(rst_n));
                         
    serializer ser_top (.i_Clk(clk),
                        .i_Clk_Fast(clk_fast),
                        .i_S_en(i_vif.ser_enable), //currently does nothing?
                        .i_Data(i_vif.in_data),
                        .o_Ser_Data(o_vif.out_data),
                        .o_10B(o_vif.out_10b));
    
    always #50ns clk = ~clk; //20MHz read
    always #1ns clk_fast = ~clk_fast; //1000MHz write
    
    initial begin
        #5 rst_n = 1'b0;
        #25 rst_n = 1'b1;
    end
    
    assign o_vif.ser_enable = i_vif.ser_enable; //not sure what this does
    
    initial begin
        uvm_config_db#(virtual serializer_if)::set(uvm_root::get(), "*.agent.*", "in_intf", i_vif);
        uvm_config_db#(virtual serializer_if)::set(uvm_root::get(), "*.monitor*", "out_intf", o_vif);
        run_test();
    end
    
endmodule

`endif
