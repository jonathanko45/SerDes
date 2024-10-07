`ifndef DES_AGENT
`define DES_AGENT

class des_agent extends uvm_agent;

    des_sequencer sequencer;
    des_driver    driver;
    des_monitor   monitor;
    
    uvm_analysis_port #(ser_transaction) slave_aport;
    
    `uvm_component_utils(des_agent)

     function new(string name, uvm_component parent);
        super.new(name, parent);
     endfunction: new
     
     function void build_phase(uvm_phase phase); //creates sequencer,driver, and monitor
        super.build_phase(phase);
        sequencer = des_sequencer::type_id::create("sequencer", this);
        driver = des_driver::type_id::create("driver", this);
        monitor = des_monitor::type_id::create("monitor", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
         driver.seq_item_port.connect(sequencer.seq_item_export);
         monitor.slave_aport.connect(sequencer.request_export); //monitor to sequencer
        `uvm_info(get_full_name(), "Connect Stage Complete", UVM_LOW)
     endfunction: connect_phase
     
endclass: des_agent

`endif