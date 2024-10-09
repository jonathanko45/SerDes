`ifndef DES_SEQUENCER
`define DES_SEQUENCER

class des_sequencer extends uvm_sequencer#(des_transaction);
    `uvm_component_utils(des_sequencer)

    uvm_analysis_export#(ser_transaction) req_export;
    uvm_tlm_analysis_fifo#(ser_transaction) request_fifo;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        request_fifo = new("request_fifo", this);
        req_export = new("req_export", this);
    endfunction: new
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        req_export.connect(request_fifo.analysis_export);
    endfunction
    
endclass: des_sequencer

`endif