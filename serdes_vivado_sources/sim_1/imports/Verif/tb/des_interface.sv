`ifndef DES_INTERFACE
`define DES_INTERFACE

interface deserializer_if
    (input clk,
     input clk_fast,
     input reset);
     
    logic [9:0] in_10b;
    logic rst_n; //maybe can merge with another reset
    logic [7:0] out_8b;
    
    logic wrst_n, w_en;
    logic rrst_n, r_en;
    
    logic full, empty;
    logic fifo_out;
    
    //for des driver, fast input
    clocking dr_cb_fast@(posedge clk_fast);
        output in_10b;
        output rst_n;
        output wrst_n;
        output w_en;
        output rrst_n;
        output r_en;
        input out_8b;
    endclocking
    modport DRV_fast (clocking dr_cb, input clk, reset);
    
    //for passive des monitor
    clocking rc_cb@(negedge clk);
        input in_10b;
        input rst_n;
        input out_8b; //might be the only value needed
        input wrst_n;
        input w_en;
        input rrst_n;
        input r_en;
        input full;
        input empty;
        input fifo_out;
    endclocking
    modport RCV (clocking rc_cb, input clk, reset);
    
endinterface: deserializer_if
    
    