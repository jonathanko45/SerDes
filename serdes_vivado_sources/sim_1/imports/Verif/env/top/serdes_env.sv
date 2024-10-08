`ifndef SERDES_ENV
`define SERDES_ENV

class serdes_env extends uvm_env;
    ser_agent s_agent;
    des_agent d_agent;
    ser_scoreboard s_sb;
    ser_ref_model ref_model;
    serdes_coverage coverage; //maybe update
    
    `uvm_component_utils(serdes_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);        
        s_agent = ser_agent::type_id::create("s_agent", this);
        d_agent = des_agent::type_id::create("d_agent", this);
        s_sb = ser_scoreboard::type_id::create("s_sb", this);
        ref_model = ser_ref_model::type_id::create("ref_model", this);
        coverage = serdes_coverage#(ser_transaction)::type_id::create("coverage", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        s_agent.s_driver.drv2rm_port.connect(ref_model.rm_export);
        s_agent.s_monitor.mon2sb_port.connect(s_sb.mon2sb_export);
        ref_model.rm2sb_port.connect(coverage.analysis_export);
        ref_model.rm2sb_port.connect(s_sb.rm2sb_export);
        `uvm_info(get_full_name(), "Connect Phase Complete", UVM_LOW)
     endfunction: connect_phase
     
endclass: serdes_env

`endif