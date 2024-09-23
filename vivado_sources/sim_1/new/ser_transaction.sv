`ifndef SER_TRANSACTION
`define SER_TRANSACTION

class ser_transaction extends uvm_sequence_item;

    rand bit ser_enable;
    rand bit [7:0] in_data;
    rand bit out_data;
    rand bit [9:0] out_10b;
    rand int delay;
   
    constraint timing {delay inside {[0 : 5]}; }
    
    `uvm_object_utils_begin(ser_transaction)
        `uvm_field_int(ser_enable,  UVM_DEFAULT)
        `uvm_field_int(in_data,     UVM_DEFAULT)
        `uvm_field_int(out_data,    UVM_DEFAULT)
        `uvm_field_int(out_10b,     UVM_DEFAULT)
        `uvm_field_int(delay,       UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "ser_transaction");
        super.new(name);
    endfunction: new
    
    virtual task displayAll();
        `uvm_info("DP", $sformatf("ser_enable = %0d in_data = %d out_data = %d out_10b = %d delay = %0d", ser_enable, in_data, out_data, out_10b, delay), UVM_LOW)
    endtask: displayAll
    
endclass: ser_transaction

`endif
