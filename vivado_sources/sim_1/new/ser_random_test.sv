`ifndef SER_RANDOM_TEST
`define SER_RANDOM_TEST

class ser_random_test extends ser_base_test;
    `uvm_component_utils(ser_random_test)
    
    function new(string name = "ser_random_test" , uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        ser_random_sequence seq;
        
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = ser_random_sequence::type_id::create("seq");
        seq.start(env.senv_in.agent.sequencer);
        phase.drop_objection(this);
     endtask: run_phase
 endclass: ser_random_test
 
 `endif