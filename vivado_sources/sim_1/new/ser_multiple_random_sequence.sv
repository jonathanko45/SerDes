`ifndef SER_MULTIPLE_RANDOM_SEQUENCE
`define SER_MULTIPLE_RANDOM_SEQUENCE

class ser_multiple_random_sequence extends uvm_sequence #(ser_transaction);
    rand int loop;
    
    constraint limit {loop inside {[5 : 10]}; }
    `uvm_object_utils(ser_multiple_random_sequence)
    
    function new(string name = "ser_multiple_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        for(int i = 0; i < loop; i++) begin
            `uvm_do(req);
        end
     endtask: body
endclass: ser_multiple_random_sequence

`endif