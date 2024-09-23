`ifndef SER_RANDOM_SEQUENCE
`define SER_RANDOM_SEQUENCE

class ser_random_sequence extends uvm_sequence #(ser_transaction);
    `uvm_object_utils(ser_random_sequence)
    
    function new(string name = "ser_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_do(req);
    endtask: body
    
endclass: ser_random_sequence

`endif