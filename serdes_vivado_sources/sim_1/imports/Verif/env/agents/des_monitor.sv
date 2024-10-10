`ifndef DES_MONITOR
`define DES_MONITOR

class des_monitor extends uvm_monitor;
    virtual interface serializer_if s_vif;
    
    //des_monitor to des_sequencer port
    uvm_analysis_port #(ser_transaction) mon2seq_port; //geting transaction from serializer intf
    ser_transaction mon_trans;
    
    bit [9:0] out_bits;
    
    `uvm_component_utils(des_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_trans = new();
        mon2seq_port = new("mon2seq_port", this);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual serializer_if)::get(this, "", "ser_intf", s_vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".s_vif"})
        `uvm_info(get_full_name(), "Build stage complete", UVM_LOW)
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        forever begin
          monitor_bus();
          mon2seq_port.write(mon_trans);
        end
    endtask : run_phase
     
    task monitor_bus();
        wait(!s_vif.reset);
        //need logic here to have equivalent of below
        //also need to pass info into a transaction
        //im thinking just a 10bit array 
        repeat (3)@(s_vif.rc_cb);
        @(s_vif.dr_cb);
        repeat(3) @(s_vif.rc_cb_fast);
        for(int i = 0; i < 10; i++) begin
            out_bits[i] <= s_vif.rc_cb_fast.out_data;
            @(s_vif.rc_cb_fast);
        end
        mon_trans.out_10b <= out_bits;
        `uvm_info(get_full_name(), "DES MONITOR pre write mon_trans", UVM_LOW)
        mon_trans.print();
    endtask
    
endclass: des_monitor

`endif