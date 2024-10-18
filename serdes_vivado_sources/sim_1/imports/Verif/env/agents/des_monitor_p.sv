`ifndef DES_MONITOR_P
`define DES_MONITOR_P

class des_monitor_p extends uvm_monitor;
    virtual interface deserializer_if d_vif;
    
    uvm_analysis_port #(des_transaction) mon_p2sb_port;
    des_transaction d_act_trans;
    
    `uvm_component_utils(des_monitor_p)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        d_act_trans = new();
        mon_p2sb_port = new("mon_p2sb_port", this);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual deserializer_if)::get(this, "", "des_intf", d_vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".d_vif"})
        `uvm_info(get_full_name(), "Build stage complete", UVM_LOW)
      endfunction: build_phase
      
     virtual task run_phase(uvm_phase phase);
        forever begin
          collect_trans();
          mon_p2sb_port.write(d_act_trans);
        end
     endtask : run_phase
      
     virtual task collect_trans();
        wait(!d_vif.reset);
        repeat(29)@(d_vif.rc_cb);
        d_act_trans.out_8b = d_vif.rc_cb.out_8b;      
        //`uvm_info(get_full_name(),$sformatf("TRANSACTION FROM passive DES MONITOR"), UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("TRANSACTION FROM passive DES MONITOR"), UVM_LOW);
        d_act_trans.print();
      endtask: collect_trans  
      
endclass: des_monitor_p

`endif
