`ifndef SER_TRANSACTION
`define SER_TRANSACTION

class ser_transaction extends uvm_sequence_item;
    
    rand int delay;
    rand bit [7:0] in_data;
    bit out_data;
    bit [9:0] out_10b;
  
    constraint timing {delay inside {[0 : 5]}; }
    
    `uvm_object_utils_begin(ser_transaction)
        `uvm_field_int(in_data, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(out_data, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(out_10b, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(delay, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name = "ser_transaction");
        super.new(name);
    endfunction: new
    
    virtual task displayAll();
        `uvm_info("DP", $sformatf("in_data = %d out_data = %d out_10b = %d delay = %0d", in_data, out_data, out_10b, delay), UVM_LOW)
    endtask: displayAll
    
endclass: ser_transaction

`endif
