`ifndef SER_AGENT
`define SER_AGENT

class ser_agent extends uvm_agent;

    ser_sequencer sequencer;
    ser_driver    driver;
    ser_monitor   monitor;
    
    `uvm_component_utils(ser_agent)

     function new(string name, uvm_component parent);
        super.new(name, parent);
     endfunction: new
     
     function void build_phase(uvm_phase phase); //creates sequencer,driver, and monitor
        super.build_phase(phase);
        sequencer = ser_sequencer::type_id::create("sequencer", this);
        driver = ser_driver::type_id::create("driver", this);
        monitor = ser_monitor::type_id::create("monitor", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
         driver.seq_item_port.connect(sequencer.seq_item_export);
        `uvm_info(get_full_name(), "Connect Stage Complete", UVM_LOW)
     endfunction: connect_phase
endclass: ser_agent

`endif