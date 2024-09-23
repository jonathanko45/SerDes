`ifndef SER_COVERAGE
`define SER_COVERAGE

class ser_coverage extends uvm_subscriber #(ser_transaction);
    ser_transaction pkt;
    int count;
    
    `uvm_component_utils(ser_coverage)
    
    covergroup cg;
        option.per_instance = 1;
        cov_ser_enable: coverpoint pkt.ser_enable;
        cov_in_data:    coverpoint pkt.in_data;
        cov_out_data:   coverpoint pkt.out_data;
        cov_out_10b:    coverpoint pkt.out_10b;
        cov_delay:      coverpoint pkt.delay;
     endgroup: cg
     
     function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
     endfunction: new
     
     function void write (ser_transaction t);
        pkt = t;
        count++;
        cg.sample();
     endfunction: write
     
     virtual function void extract_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Number of coverage packets collected = %0d", count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Current coverage = %0f", cg.get_coverage()), UVM_LOW)
     endfunction: extract_phase
     
 endclass: ser_coverage
 
`endif
