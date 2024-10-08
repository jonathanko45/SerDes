`ifndef DES_SEQUENCER
`define DES_SEQUENCER

class des_sequencer extends uvm_sequencer#(des_transaction);

    uvm_analysis_export#(ser_transaction) req_export;
    uvm_tlm_analysis_fifo#(ser_transaction) req_fifo;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        req_export = new("req_export", this);
        req_fifo = new("req_fifo", this);
    endfunction: new
    
    function void connect_phase(uvm_phase phase);
        req_export.connect(req_fifo.analysis_export);
    endfunction
    
endclass: des_sequencer

`endif