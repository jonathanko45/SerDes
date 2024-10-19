`ifndef SER_TRANSACTION
`define SER_TRANSACTION

class ser_transaction extends uvm_sequence_item;
    
    rand bit [7:0] in_data;
    rand bit signed [1:0] in_RD;
    
    bit out_data;
    bit [9:0] out_10b;
    bit signed [1:0] out_RD;
    
    int RD;

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
    
    constraint in_data_c {in_data inside {[8'b000000000:8'b11111111]}; }
    constraint in_RD_c {in_RD inside {2'sb11, 2'sb01}; }
      
    function void post_randomize();
        uvm_config_db#(int)::get(m_sequencer, "*", "running_disparity", RD);
        in_RD = RD;
    endfunction
    
endclass: ser_transaction

`endif
