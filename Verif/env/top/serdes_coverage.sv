`ifndef SERDES_COVERAGE
`define SERDES_COVERAGE

class serdes_coverage extends uvm_subscriber #(ser_transaction);
    ser_transaction cov_trans;
    int count;
    
    `uvm_component_utils(serdes_coverage)
    
    covergroup cg;
        option.per_instance = 1;
        option.goal = 100;

        cov_in_data:    coverpoint cov_trans.in_data {bins in_values[] = {[0:$]};}
        cov_out_10b:    coverpoint cov_trans.out_10b {bins out_10b_1 = {1}; bins out_10b_0  = {0};}
     endgroup: cg
     
     function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
        cov_trans = new();
     endfunction: new
     
     function void write (ser_transaction t);
        this.cov_trans = t;
        count++;
        cg.sample();
     endfunction: write
     
     virtual function void extract_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Number of coverage packets collected = %0d", count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Current coverage = %0f", cg.get_coverage()), UVM_LOW)
     endfunction: extract_phase
     
 endclass: serdes_coverage
 
`endif
