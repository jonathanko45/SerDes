`ifndef DES_AGENT
`define DES_AGENT

class des_agent extends uvm_agent;

    des_sequencer d_sequencer;
    des_driver    d_driver;
    des_monitor   d_monitor;
    
    `uvm_component_utils(des_agent)

     function new(string name, uvm_component parent);
        super.new(name, parent);
     endfunction: new
     
     function void build_phase(uvm_phase phase); //creates sequencer,driver, and monitor
        super.build_phase(phase);
        d_sequencer = des_sequencer::type_id::create("d_sequencer", this);
        d_driver = des_driver::type_id::create("d_driver", this);
        d_monitor = des_monitor::type_id::create("d_monitor", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
        d_driver.seq_item_port.connect(d_sequencer.seq_item_export);
        d_monitor.mon2seq_port.connect(d_sequencer.req_export); //monitor to sequencer
        `uvm_info(get_full_name(), "Connect Stage Complete", UVM_LOW)
     endfunction: connect_phase
     
endclass: des_agent

`endif