`ifndef DES_MONITOR
`define DES_MONITOR

class des_monitor extends uvm_monitor;
    virtual interface serializer_if vif;
    
    //des_monitor to des_sequencer port
    uvm_analysis_port #(ser_transaction) mon2seq_port; //geting transaction from serializer intf
    ser_transaction mon_trans;
    
    `uvm_component_utils(des_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_trans = new();
        mon2seq_port = new("mon2seq_port", this);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual serializer_if)::get(this, "", "intf", vif))
            `uvm_fatal("NOVIF", ("Virtual Interface must be set for: ", get_full_name(), ".vif"))
        `uvm_info(get_full_name(), "Build stage complete", UVM_LOW)
    endfunction: build_phase
    
    task monitor_bus();
        forever begin
        
            //need logic here to have equivalent of below
            //also need to pass info into a transaction
            //im thinking just a 10bit array 
            /*
            repeat(10) begin
                mon_queue.push_back(vif.rc_cb_fast.out_data);
                @(vif.rc_cb_fast);
            end
            */
            mon2seq_port.write(mon_trans);
        end
    endtask
    
endclass: des_monitor

`endif