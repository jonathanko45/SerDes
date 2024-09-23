`ifndef SER_BASE_TEST
`define SER_BASE_TEST

class ser_base_test extends uvm_test;
    `uvm_component_utils(ser_base_test)
    
    dut_env env;
    uvm_table_printer printer;
    
    function new(string name = "ser_base_test" , uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dut_env::type_id::create("env", this);
        printer = new();
        printer.knobs.depth = 5;
     endfunction: build_phase
     
     virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Printing the test topology : \n%s", this.sprint(printer)), UVM_DEBUG)
     endfunction: end_of_elaboration_phase
     
     virtual task run_phase(uvm_phase phase);
        phase.phase_done.set_drain_time(this, 1500);
    endtask: run_phase
endclass: ser_base_test

`endif