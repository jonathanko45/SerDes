`ifndef SER_BASE_TEST
`define SER_BASE_TEST

class ser_base_test extends uvm_test;
    `uvm_component_utils(ser_base_test)
    
    ser_env env;
    ser_basic_sequence seq;
    
    function new(string name = "ser_base_test" , uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ser_env::type_id::create("env", this);
        seq = ser_basic_sequence::type_id::create("seq");
     endfunction: build_phase
     
     virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask: run_phase
endclass: ser_base_test

`endif