`ifndef SER_MONITOR
`define SER_MONITOR

class ser_monitor extends uvm_monitor;
    virtual interface serializer_if vif;
    string monitor_intf;
    int num_pkts;
    
    uvm_analysis_port #(ser_transaction) item_collected_port;
    ser_transaction data_collected;
    ser_transaction data_clone;
    
    `uvm_component_utils(ser_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(!uvm_config_db#(string)::get(this, "", "monitor_intf", monitor_intf))
            `uvm_fatal("NOSTRING", {"Need interface name for: ", get_full_name(), ".monitor_intf"})
         
         `uvm_info(get_type_name(), $sformatf("INTERFACE USED = %0s", monitor_intf), UVM_LOW)
         if(!uvm_config_db#(virtual serializer_if)::get(this, "", "monitor_intf", vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".vif"})
            
         item_collected_port = new("item_collected_port", this);
         data_collected = ser_transaction::type_id::create("data_collected");
         data_clone = ser_transaction::type_id::create("data_clone");
         
         `uvm_info(get_full_name(), "Build state complete", UVM_LOW)
      endfunction: build_phase
      
      virtual task collect_data();
        forever begin
            wait(vif.ser_enable)
            data_collected.in_data = vif.in_data;
            //maybe do this instead
            /*
            wait(vif.enable)
            data_collected.in_data = vif.in_data;
            repeat(2) @(posedge vif.clk);
            data_collected.out_data = vif.out_data;
            @(posedge vif.clk);
            data_collected.out_data = vif.out_data;
            ... 
            12 times to get each bit
            could be issue that out_data gets overwritten, maybe need to pass it off some way
            */
            repeat(12) @(posedge vif.clk);
            data_collected.out_data = vif.out_data;
            data_collected.out_10b = vif.out_10b;
            $cast(data_clone, data_collected.clone());
            item_collected_port.write(data_clone);
            num_pkts++;
         end
      endtask: collect_data
      
      virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("REPORT: PACKETS COLLECTED = %0d", num_pkts), UVM_LOW)
     endfunction: report_phase
endclass: ser_monitor

`endif
