`ifndef SER_TRANSACTION
`define SER_TRANSACTION

class ser_transaction extends uvm_sequence_item;
    
    rand bit [7:0] in_data;
    int in_RD;
    
    bit out_data;
    bit [9:0] out_10b;
    int out_RD;

    `uvm_object_utils_begin(ser_transaction)
        `uvm_field_int(in_data, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(in_RD, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(out_data, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(out_10b, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(out_RD, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    function new(string name = "ser_transaction");
        super.new(name);
    endfunction: new
    
    constraint in_data__c {in_data inside {[8'b000000000:8'b11111111]}; }
    constraint in_RD_c {in_RD inside {2'sb01, 2'sb11}; }
    constraint out_RD_c {out_RD inside {2'sb01, 2'sb11}; }
      
    function void post_randomize();
    endfunction
    
endclass: ser_transaction

`endif
