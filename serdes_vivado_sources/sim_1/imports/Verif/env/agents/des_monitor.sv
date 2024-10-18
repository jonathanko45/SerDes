`ifndef DES_MONITOR
`define DES_MONITOR

class des_monitor extends uvm_monitor;
    virtual interface serializer_if s_vif;
    
    //des_monitor to des_sequencer port
    uvm_analysis_port #(ser_transaction) mon2seq_port; //geting transaction from serializer intf
    ser_transaction mon_trans;
    uvm_event des_done;
    
    bit [9:0] out_bits;
    bit first_seq;
    
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
        if(!uvm_config_db#(uvm_event)::get(this, "", "des_done", des_done))
            `uvm_fatal("NOEVENT", {"Failed to get uvm_event in: ", get_full_name()})
        `uvm_info(get_full_name(), "Build stage complete", UVM_LOW)
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        forever begin
          monitor_bus();
          mon2seq_port.write(mon_trans);
          des_done.wait_trigger;
        end
    endtask : run_phase
     
    task monitor_bus();
        if(s_vif.reset) first_seq <= 1;
        wait(!s_vif.reset);
        if(first_seq == 1) begin
            first_seq <= 0;
            @(s_vif.rc_cb);  
        end
        repeat (2)@(s_vif.rc_cb);
        @(s_vif.dr_cb);
        repeat(3) @(s_vif.rc_cb_fast);
        for(int i = 0; i < 10; i++) begin
            out_bits[i] <= s_vif.rc_cb_fast.out_data;
            @(s_vif.rc_cb_fast);
        end
        @(s_vif.rc_cb);

        mon_trans.out_10b = out_bits;
        `uvm_info(get_type_name(), "DES MONITOR write to sequencer", UVM_LOW)
        //`uvm_info(get_full_name(), "DES MONITOR pre write mon_trans", UVM_LOW)
        mon_trans.print();
    endtask
    
endclass: des_monitor

`endif