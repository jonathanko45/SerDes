`ifndef SER_AGENT
`define SER_AGENT

class ser_agent extends uvm_agent;

    ser_sequencer s_sequencer;
    ser_driver    s_driver;
    ser_monitor   s_monitor;
    
    `uvm_component_utils(ser_agent)

     function new(string name, uvm_component parent);
        super.new(name, parent);
     endfunction: new
     
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s_sequencer = ser_sequencer::type_id::create("s_sequencer", this);
        s_driver = ser_driver::type_id::create("s_driver", this);
        s_monitor = ser_monitor::type_id::create("s_monitor", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
         s_driver.seq_item_port.connect(s_sequencer.seq_item_export);
        `uvm_info(get_full_name(), "Connect Stage Complete", UVM_LOW)
     endfunction: connect_phase
endclass: ser_agent

`endif