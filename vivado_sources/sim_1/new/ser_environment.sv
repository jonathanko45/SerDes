`ifndef SER_ENV
`define SER_ENV

class ser_env extends uvm_env;
    ser_agent agent;
    ser_scoreboard sb;
    sert_ref_model ref_model;
    ser_coverage coverage;
    
    `uvm_component_utils(ser_env)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);        
        agent = ser_agent::type_id::create("agent", this);
        sb = ser_scoreboard::type_id::create("sb", this);
        ref_model = adder_4_bit_ref_model::type_id::create("ref_model", this);
        coverage = ser_coverage#(ser_transaction)::type_id::create("coverage", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.driver.drv2rm_port.connect(ref_model.rm_export);
        agent.monitor.mon2sb_port.connect(sb.mon2sb_export);
        ref_model.rm2sb_port.connect(coverage.analysis_export);
        ref_model.rm2sb_port.connect(sb.rm2sb_export);
        `uvm_info(get_full_name(), "Connect Phase Complete", UVM_LOW)
     endfunction: connect_phase
     
endclass: ser_env

`endif