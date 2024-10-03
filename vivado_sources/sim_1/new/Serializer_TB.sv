`ifndef SERIALIZER_TB
`define SERIALIZER_TB

 `include "uvm_macros.svh"
import uvm_pkg::*;

module Serializer_TB;
   
   import ser_test_lib::*;
    
    bit clk;
    bit clk_fast;
    bit reset;

    serializer_if ser_intf (.clk(clk),
                            .clk_fast(clk_fast),
                            .reset(reset));
                         
    serializer ser_top (.i_Clk(clk),
                        .i_Clk_Fast(clk_fast),
                        .i_rst_n(ser_intf.rst_n),
                        .i_Data(ser_intf.in_data),
                        .i_RD(ser_intf.in_RD),
                        .o_Ser_Data(ser_intf.out_data),
                        .o_10B(ser_intf.out_10b),
                        .o_RD(ser_intf.out_RD));
    
    always #50ns clk = ~clk; //20MHz read
    always #1ns clk_fast = ~clk_fast; //1000MHz write
    
    initial begin
        reset = 1;
        @(posedge clk);
        reset = 0;
    end

    initial begin
        uvm_config_db#(virtual serializer_if)::set(uvm_root::get(), "*", "intf", ser_intf);
        uvm_config_db#(int)::set(null, "*", "running_disparity", 2'sb11); //initial setting of RD
        run_test();
    end
    
endmodule

`endif
