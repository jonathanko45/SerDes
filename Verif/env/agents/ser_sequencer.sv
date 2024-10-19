`ifndef SER_SEQUENCER
`define SER_SEQUENCER

class ser_sequencer extends uvm_sequencer #(ser_transaction);
    `uvm_component_utils(ser_sequencer)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
endclass: ser_sequencer

`endif





