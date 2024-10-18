`ifndef DES_SLAVE_SEQUENCE
`define DES_SLAVE_SEQUENCE

class des_slave_sequence extends uvm_sequence #(des_transaction);
    `uvm_object_utils(des_slave_sequence)
    `uvm_declare_p_sequencer(des_sequencer)
   
    des_transaction slave_req;
    ser_transaction mon_trans;
    
    function new(string name = "des_slave_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        forever begin
            p_sequencer.d_seq_exp_fifo.get(mon_trans); //blocking until gets transaction from montior
            //copy data from ser_transaction into a new des_transaction
            slave_req = des_transaction::type_id::create("slave_req");
            start_item(slave_req);
            slave_req.in_10b = mon_trans.out_10b;
            `uvm_info(get_full_name(), $sformatf("new TRANSACTION FROM des_SEQUENCE"), UVM_LOW);
            slave_req.print();
            finish_item(slave_req); //sends item to driver
        end
    endtask: body
    
endclass: des_slave_sequence

`endif
