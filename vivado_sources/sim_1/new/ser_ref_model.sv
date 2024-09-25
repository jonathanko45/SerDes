`ifndef SER_REF_MODEL
`define SER_REF_MODEL

class ser_ref_model extends uvm_component;
    
    `uvm_component_utils(ser_ref_model);
    
    uvm_analysis_export#(ser_transaction) rm_export;
    uvm_analysis_port#(ser_transaction) rm2sb_port;
    ser_transaction exp_trans,rm_trans;
    uvm_tlm_analysis_fifo#(ser_transaction) rm_exp_fifo;
    
    function new(string name = "ser_ref_model", uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rm_export = new("rm_export", this);
        rm2sb_port = new("rm2sb_port", this);
        rm_exp_fifo = new("rm_exp_fifo", this);
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        rm_export.connect(rm_exp_fifo.analysis_export);
    endfunction: connect_phase
    
    task run_phase(uvm_phase phase);
        forever begin
            rm_exp_fifo.get(rm_trans);
            get_expected_transaction(rm_trans);
        end
     endtask
     
     task get_expected_transaction(ser_transaction rm_trans);
        this.exp_trans = rm_trans;
        `uvm_info(get_full_name(), $sformatf("EXPECTED TRANSACTION FROM REF MODEL"), UVM_LOW);
        exp_trans.print();
        
        //TODO ref model logic goes here
        //{exp_trans.cout,exp_trans.sum} = exp_trans.x + exp_trans.y + exp_trans.cin ; 
        //the {} are doing reverse concatination, assiging the MSB to to cout and other bits to sum
        
        rm2sb_port.write(exp_trans);
     endtask
endclass

`endif
     
