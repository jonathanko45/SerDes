`ifndef DES_SEQUENCER
`define DES_SEQUENCER

class des_sequencer extends uvm_sequencer#(des_transaction);
    `uvm_component_utils(des_sequencer)

    uvm_analysis_export#(ser_transaction) d_seq_export;
    uvm_tlm_analysis_fifo#(ser_transaction) d_seq_exp_fifo;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        d_seq_exp_fifo = new("d_seq_exp_fifo", this);
        d_seq_export = new("d_seq_export", this);
    endfunction: new
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d_seq_export.connect(d_seq_exp_fifo.analysis_export);
    endfunction
    
endclass: des_sequencer

`endif