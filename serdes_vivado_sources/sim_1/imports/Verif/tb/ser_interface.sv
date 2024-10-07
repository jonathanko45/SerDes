`ifndef SER_INTERFACE
`define SER_INTERFACE

interface serializer_if
    (input clk,
     input clk_fast,
     input reset);
    
    logic [7:0] in_data;
    logic signed [1:0] in_RD;
    logic rst_n;
    logic out_data;
    logic [9:0] out_10b;
    logic signed [1:0] out_RD;
    
    //for driver
    clocking dr_cb@(posedge clk);
        output in_data;
        output in_RD;
        output rst_n;
        input out_10b;
        input out_RD;
    endclocking
    modport DRV (clocking dr_cb, input clk, reset);
    
    //for monitor
    clocking rc_cb@(negedge clk);
        input in_data;
        input in_RD;
        input rst_n;
        input out_10b;
        input out_RD;
    endclocking
    modport RCV (clocking rc_cb, input clk, reset);
    
    //montior fast output
    clocking rc_cb_fast@(posedge clk_fast);
        input out_data;
    endclocking
    modport RCV_fast (clocking rc_cb_fast, input clk_fast, reset);
    
endinterface: serializer_if

`endif
