`ifndef SER_SCOREBOARD
`define SER_SCOREBOARD

class ser_scoreboard extends uvm_scoreboard;
    uvm_tlm_analysis_fifo #(ser_transaction) input_packets_collected;
    uvm_tlm_analysis_fifo #(ser_transaction) output_packets_collected;
    
    ser_transaction input_packet;
    ser_transaction output_packet;
    
    `uvm_component_utils(ser_scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        input_packets_collected = new("input_packets_collected", this); //'this' uses to be 'new'
        output_packets_collected = new("output_packets_collected", this); //'this' uses to be 'new'
        
        input_packet = ser_transaction::type_id::create("input_packet", this);
        output_packet = ser_transaction::type_id::create("output_packet", this);
        
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
     endfunction: build_phase
     
    virtual task run_phase(uvm_phase phase);
        watcher();
    endtask: run_phase
    
    virtual task watcher();
        forever begin
            input_packets_collected.get(input_packet);
            output_packets_collected.get(output_packet);
            compare_data();
         end
    endtask: watcher
    
    virtual task compare_data();
    //this holds all code thats needed to compare input vs output and check if matches expected
    // >>>>> TO DO <<<<<<
    endtask: compare_data
    
endclass: ser_scoreboard
    
`endif