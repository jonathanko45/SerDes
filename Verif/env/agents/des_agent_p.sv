`ifndef DES_AGENT_P
`define DES_AGENT_P

class des_agent_p extends uvm_agent;
    des_monitor_p   d_monitor_p;
    
    `uvm_component_utils(des_agent_p)

     function new(string name, uvm_component parent);
        super.new(name, parent);
     endfunction: new
     
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d_monitor_p = des_monitor_p::type_id::create("d_monitor_p", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase

endclass: des_agent_p

`endif
