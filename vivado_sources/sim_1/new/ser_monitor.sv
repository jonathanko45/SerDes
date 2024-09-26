`ifndef SER_MONITOR
`define SER_MONITOR

class ser_monitor extends uvm_monitor;
    virtual interface serializer_if vif;
    int num_pkts;
    
    uvm_analysis_port #(ser_transaction) mon2sb_port;
    ser_transaction act_trans;
    
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
         `uvm_info(get_full_name(), "Build state complete", UVM_LOW)
      endfunction: build_phase
      
      virtual task run_phase(uvm_phase phase);
        forever begin
          collect_trans();
          mon2sb_port.write(act_trans);
        end
      endtask : run_phase
      
      virtual task collect_trans();
         wait(!vif.rst_n);
         repeat (12) @(vif.rc_cb);  

        
            //maybe do this instead
            /*
            wait(vif.enable)
            act_trans.in_data = vif.in_data;
            repeat(2) @(posedge vif.clk);
            act_trans.out_data = vif.out_data;
            @(posedge vif.clk);
            act_trans.out_data = vif.out_data;
            ... 
            12 times to get each bit
            could be issue that out_data gets overwritten, maybe need to pass it off some way
            */
         
         act_trans.in_data = vif.rc_cb.in_data;
         //act_trans.out_data = vif.rc_cb.out_data;
         act_trans.out_10b = vif.rc_cb.out_10b;
         num_pkts++;
         `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
         act_trans.print();
      endtask: collect_trans
      
      virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("REPORT: PACKETS COLLECTED = %0d", num_pkts), UVM_LOW)
     endfunction: report_phase
endclass: ser_monitor

`endif
