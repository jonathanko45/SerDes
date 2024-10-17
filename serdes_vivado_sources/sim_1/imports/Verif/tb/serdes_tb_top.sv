`ifndef SERDES_TB_TOP
`define SERDES_TB_TOP

`include "uvm_macros.svh"
`include "ser_interface.sv"
`include "des_interface.sv"
import uvm_pkg::*;

module serdes_tb_top;
   
   import serdes_test_lib::*;
    
    bit clk;
    bit clk_fast;
    bit reset;
    
    serializer_if ser_intf (.clk(clk),
                            .clk_fast(clk_fast),
                            .reset(reset));
    
    deserializer_if des_intf (.clk(clk),
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

    deserializer des_top (.i_Wclk(clk_fast),    
                          .i_Wrst_n(des_intf.wrst_n), 
                          .i_W_en(des_intf.w_en), 
                          .i_Rclk(clk), 
                          .i_Rrst_n(des_intf.rrst_n), 
                          .i_R_en(des_intf.r_en),
                          .i_rst_n(des_intf.rst_n), 
                          .i_Data_In(des_intf.in_data), 
                          .o_Data(des_intf.out_8b),
                          .o_FIFO_Out(), //not sure if need these
                          .o_full(), 
                          .o_empty());
    
    always #50ns clk = ~clk; //20MHz read
    always #1ns clk_fast = ~clk_fast; //1000MHz write
    
    initial begin
        reset = 1;
        #300ns
        reset = 0;
    end

    initial begin
        uvm_config_db#(virtual serializer_if)::set(uvm_root::get(), "*", "ser_intf", ser_intf);
        uvm_config_db#(virtual deserializer_if)::set(uvm_root::get(), "*", "des_intf", des_intf); //might need to rename "intf"
        uvm_config_db#(int)::set(null, "*", "running_disparity", 2'sb11); //initial setting of RD
        run_test();
    end
    
endmodule

`endif