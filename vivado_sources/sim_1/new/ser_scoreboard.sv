`ifndef SER_SCOREBOARD
`define SER_SCOREBOARD

class ser_scoreboard extends uvm_scoreboard;
    //analysis ports and exports 
    //rm = reference model, mon = monitor, sb = scoreboard
    uvm_analysis_export#(ser_transaction) rm2sb_export,  mon2sb_export;
    uvm_tlm_analysis_fifo #(ser_transaction) rm2sb_export_fifo, mon2sb_export_fifo;
    ser_transaction exp_trans, act_trans;
    ser_transaction exp_trans_fifo[$], act_trans_fifo[$];
    bit error;
    
    uvm_queue#(int) mon_queue = uvm_queue_pool::get_global("queue_key_mon");
    uvm_queue#(int) rm_queue = uvm_queue_pool::get_global("queue_key_rm");
    int exp_ser, act_ser;
    `uvm_component_utils(ser_scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rm2sb_export = new("rm2sb_export", this);
        mon2sb_export = new("mon2sb_export", this);
        rm2sb_export_fifo = new("rm2sb_export_fifo", this);
        mon2sb_export_fifo = new("mon2sb_export_fifo", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
    endfunction: build_phase
     
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        rm2sb_export.connect(rm2sb_export_fifo.analysis_export);
        mon2sb_export.connect(mon2sb_export_fifo.analysis_export);
    endfunction: connect_phase
    
    //comparing expected and actual transactions 
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            mon2sb_export_fifo.get(act_trans);
            if(act_trans==null) $stop;
            act_trans_fifo.push_back(act_trans);
            
            rm2sb_export_fifo.get(exp_trans);
            if(exp_trans==null) $stop;
            exp_trans_fifo.push_back(exp_trans);
            compare_trans();
        end
    endtask: run_phase
    
    virtual task compare_trans();
        ser_transaction exp_trans, act_trans;
        if (exp_trans_fifo.size != 0) begin
            exp_trans = exp_trans_fifo.pop_front();
            if(act_trans_fifo.size != 0) begin
                act_trans = act_trans_fifo.pop_front();
                `uvm_info(get_full_name(), $sformatf("expected 10b = %b, actual 10b = %b ", exp_trans.out_10b, act_trans.out_10b), UVM_LOW);
                
                `uvm_info(get_full_name(), $sformatf("expected serial out | actual serial out"), UVM_LOW);
                repeat (10) begin
                    act_ser = mon_queue.pop_front();
                    exp_ser = rm_queue.pop_front();
                    if (act_ser != exp_ser) error = 1;
                    `uvm_info(get_full_name(), $sformatf("                  %0b | %0b ", exp_ser, act_ser), UVM_LOW);
                end
                
                if (exp_trans.out_10b == act_trans.out_10b) begin
                    `uvm_info(get_full_name(), $sformatf("10b MATCHES"), UVM_LOW);
                end else begin
                    `uvm_info(get_full_name(), $sformatf("10b INCORRECT"), UVM_LOW);
                    error = 1;
                end
                
                if (error != 1) begin
                    `uvm_info(get_full_name(), $sformatf("SERIAL DATA MATCHES"), UVM_LOW);
                end else begin
                    `uvm_info(get_full_name(), $sformatf("SERIAL DATA IS INCORRECT"), UVM_LOW);
                end
                
               
             end   
        end            
    endtask: compare_trans
    
    function void report_phase(uvm_phase phase);
        if(error==0) begin
          $write("%c[7;32m",27);
          $display("-------------------------------------------------");
          $display("------ INFO : TEST CASE PASSED ------------------");
          $display("-----------------------------------------");
          $write("%c[0m",27);
        end else begin
          $write("%c[7;31m",27);
          $display("---------------------------------------------------");
          $display("------ ERROR : TEST CASE FAILED ------------------");
          $display("---------------------------------------------------");
          $write("%c[0m",27);
        end
    endfunction: report_phase
    
endclass: ser_scoreboard
    
`endif