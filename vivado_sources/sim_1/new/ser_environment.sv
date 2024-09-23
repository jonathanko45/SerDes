`ifndef SER_ENV
`define SER_ENV

class ser_env extends uvm_env;
    ser_agent agent;
    
    `uvm_component_utils(ser_env)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = ser_agent::type_id::create("agent", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
endclass: ser_env

class dut_env extends uvm_env;
    ser_env        senv_in;
    ser_env        senv_out;
    ser_scoreboard sb;
    
    `uvm_component_utils(dut_env)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        uvm_config_db#(int)::set(this, "senv_in.agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(int)::set(this, "senv_out.agent", "is_active", UVM_PASSIVE);
        
        uvm_config_db#(string)::set(this, "senv_in.agent.monitor", "monitor_intf", "in_intf");
        uvm_config_db#(string)::set(this, "senv_out.agent.monitor", "monitor_intf", "out_intf");
        
        senv_in = ser_env::type_id::create("penv_in", this);
        senv_out = ser_env::type_id::create("penv_out", this);
        sb       = ser_scoreboard::type_id::create("sb", this);
        
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
     function void connect_phase(uvm_phase phase);
        senv_in.agent.monitor.item_collected_port.connect(sb.input_packets_collected.analysis_export);
        senv_out.agent.monitor.item_collected_port.connect(sb.output_packets_collected.analysis_export);
        `uvm_info(get_full_name(), "Connect Phase Complete", UVM_LOW)
     endfunction: connect_phase
     
 endclass: dut_env
 
 `endif