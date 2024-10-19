`ifndef SERDES_BASE_TEST
`define SERDES_BASE_TEST

class serdes_base_test extends uvm_test;
    `uvm_component_utils(serdes_base_test)
    
    serdes_env env;
    ser_basic_sequence seq;
    des_slave_sequence slave_seq;
    
    function new(string name = "ser_base_test" , uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = serdes_env::type_id::create("env", this);
        seq = ser_basic_sequence::type_id::create("seq");
        slave_seq = des_slave_sequence::type_id::create("slave_seq");
     endfunction: build_phase
     
     virtual task run_phase(uvm_phase phase);
        fork 
            slave_seq.start(env.d_agent.d_sequencer);
        join_none
        phase.raise_objection(this);
        seq.start(env.s_agent.s_sequencer);
        phase.drop_objection(this);
    endtask: run_phase
     
endclass: serdes_base_test

`endif