`ifndef DES_TRANSACTION
`define DES_TRANSACTION

class des_transaction extends uvm_sequence_item;
    
    bit [9:0] in_10b;
    
    `uvm_object_utils_begin(des_transaction)
        `uvm_field_int(in_10b, UVM_DEFAULT | UVM_BIN)
    `uvm_object_utils_end
    
    function new(string name = "des_transaction");
        super.new(name);
    endfunction: new
    
endclass: des_transaction

`endif