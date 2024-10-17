`ifndef SER_MONITOR
`define SER_MONITOR

class ser_monitor extends uvm_monitor;
    virtual interface serializer_if s_vif;
    
    uvm_analysis_port #(ser_transaction) mon2sb_port;
    ser_transaction act_trans;
    uvm_queue#(int) mon_queue = uvm_queue_pool::get_global("queue_key_mon");
    uvm_event des_done;
    
    `uvm_component_utils(ser_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        act_trans = new();
        mon2sb_port = new("mon2sb_port", this);
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
          collect_trans();
          mon2sb_port.write(act_trans);
          des_done.wait_trigger;
        end
     endtask : run_phase
      
     virtual task collect_trans();
        wait(!s_vif.reset);
        `uvm_info(get_type_name(), "post reset ser_monitor", UVM_LOW);
        repeat (3)@(s_vif.rc_cb);
        @(s_vif.dr_cb);
        repeat (3) @(s_vif.rc_cb_fast);
        `uvm_info(get_type_name(), "ser_monitor starting to collect fast bits", UVM_LOW);
        repeat(10) begin
           mon_queue.push_back(s_vif.rc_cb_fast.out_data);
           @(s_vif.rc_cb_fast);
        end
        @(s_vif.rc_cb);
         `uvm_info(get_type_name(), "ser_monitor collecting final states", UVM_LOW);
        act_trans.in_data = s_vif.rc_cb.in_data;
        act_trans.in_RD = s_vif.rc_cb.in_RD;
        act_trans.out_10b = s_vif.rc_cb.out_10b;
        act_trans.out_RD = s_vif.rc_cb.out_RD;
        uvm_config_db #(int)::set(null, "*", "running_disparity", act_trans.out_RD);           
        `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
        act_trans.print();
      endtask: collect_trans  
endclass: ser_monitor

`endif
