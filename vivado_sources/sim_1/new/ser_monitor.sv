`ifndef SER_MONITOR
`define SER_MONITOR

class ser_monitor extends uvm_monitor;
    virtual interface serializer_if vif;
    int num_pkts;
    int RD;
    
    uvm_analysis_port #(ser_transaction) mon2sb_port;
    ser_transaction act_trans;
    uvm_queue#(int) mon_queue = uvm_queue_pool::get_global("queue_key_mon");
    
    `uvm_component_utils(ser_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        act_trans = new();
        mon2sb_port = new("mon2sb_port", this);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         if(!uvm_config_db#(virtual serializer_if)::get(this, "", "intf", vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".vif"})
         if(!uvm_config_db#(int)::get(this, "", "running_disparity", RD))
            `uvm_fatal("NO RD", {"Running Disparity must be set for: ", get_full_name(), ".RD"})
         `uvm_info(get_full_name(), "Build state complete", UVM_LOW)
      endfunction: build_phase
      
      virtual task run_phase(uvm_phase phase);
        forever begin
          collect_trans();
          mon2sb_port.write(act_trans);
        end
      endtask : run_phase
      
      virtual task collect_trans();
         wait(!vif.reset);
         repeat (4) @(vif.rc_cb);
        
            //maybe do this instead
            /*

            act_trans.in_data = vif.in_data;
            repeat(2) @(posedge vif.rc_cb_fast);
            act_trans.out_data = vif.rc_cb_fast.out_data;
            @(posedge vif.rc_cb_fast);
            act_trans.out_data = vif.rc_cb_fast.out_data;
            ... 
            12 times to get each bit
   
            */
         
         act_trans.in_data = vif.rc_cb.in_data;
         act_trans.in_RD = vif.rc_cb.in_RD;;
         
         //act_trans.out_data = vif.rc_cb.out_data;
         act_trans.out_10b = vif.rc_cb.out_10b;
         act_trans.out_RD = vif.rc_cb.out_RD;
         uvm_config_db #(int)::set(null, "*", "running_disparity", vif.rc_cb.out_RD); 
         
         num_pkts++;
         `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
         act_trans.print();
      endtask: collect_trans
      
      virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("REPORT: PACKETS COLLECTED = %0d", num_pkts), UVM_LOW)
     endfunction: report_phase
endclass: ser_monitor

`endif
