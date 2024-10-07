`ifndef SER_BASIC_SEQUENCE
`define SER_BASIC_SEQUENCE

class ser_basic_sequence extends uvm_sequence #(ser_transaction);
    `uvm_object_utils(ser_basic_sequence)
   
    function new(string name = "ser_basic_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        for(int i = 0; i < 5; i++) begin
            req = ser_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"), UVM_LOW);
            req.print();
            finish_item(req);
            get_response(rsp); //getting response from clone sent to ref model
        end
    endtask: body
    
endclass: ser_basic_sequence

`endif
