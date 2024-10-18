`ifndef SERDES_SCOREBOARD
`define SERDES_SCOREBOARD

class serdes_scoreboard extends uvm_scoreboard;
    //rm = reference model, mon = monitor, sb = scoreboard
    uvm_analysis_export#(ser_transaction) rm2sb_export,  mon2sb_export;
    uvm_analysis_export#(des_transaction) mon_p2sb_export;
    uvm_tlm_analysis_fifo#(ser_transaction) rm2sb_export_fifo, mon2sb_export_fifo;
    uvm_tlm_analysis_fifo#(des_transaction) mon_p2sb_export_fifo;
    ser_transaction exp_trans, act_trans;
    ser_transaction exp_trans_fifo[$], act_trans_fifo[$];
    des_transaction d_act_trans;
    des_transaction d_act_trans_fifo[$];
    uvm_event des_done;
    
    bit error;
    
    uvm_queue#(int) mon_queue = uvm_queue_pool::get_global("queue_key_mon");
    uvm_queue#(int) rm_queue = uvm_queue_pool::get_global("queue_key_rm");
    int exp_ser, act_ser;
    `uvm_component_utils(serdes_scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rm2sb_export = new("rm2sb_export", this);
        mon2sb_export = new("mon2sb_export", this);
        mon_p2sb_export = new("mon_p2sb_export", this);
        rm2sb_export_fifo = new("rm2sb_export_fifo", this);
        mon2sb_export_fifo = new("mon2sb_export_fifo", this);
        mon_p2sb_export_fifo = new("mon_p2sb_export_fifo", this);
        if(!uvm_config_db#(uvm_event)::get(this, "", "des_done", des_done))
            `uvm_fatal("NOEVENT", {"Failed to get uvm_event in: ", get_full_name()})
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
    endfunction: build_phase
     
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        rm2sb_export.connect(rm2sb_export_fifo.analysis_export);
        mon2sb_export.connect(mon2sb_export_fifo.analysis_export);
        mon_p2sb_export.connect(mon_p2sb_export_fifo.analysis_export);
    endfunction: connect_phase
    
    //comparing expected and actual transactions 
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            mon2sb_export_fifo.get(act_trans);
            if(act_trans == null) $stop;
            act_trans_fifo.push_back(act_trans);
            
            rm2sb_export_fifo.get(exp_trans);
            if(exp_trans == null) $stop;
            exp_trans_fifo.push_back(exp_trans);
            
            compare_ser_trans();
            
            mon_p2sb_export_fifo.get(d_act_trans);
            if(d_act_trans == null) $stop;
            d_act_trans_fifo.push_back(d_act_trans);
            
            compare_des_trans();
            
            des_done.trigger;
        end
    endtask: run_phase
    
    virtual task compare_ser_trans();
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
                    assert(act_ser == exp_ser) begin
                        `uvm_info(get_full_name(), $sformatf("                  %0b | %0b ", exp_ser, act_ser), UVM_LOW);
                    end else
                        error = 1;
                end
                
                assert(exp_trans.out_10b == act_trans.out_10b) begin
                    `uvm_info(get_full_name(), $sformatf("10b MATCHES"), UVM_LOW);
                end else begin
                    `uvm_info(get_full_name(), $sformatf("10b INCORRECT"), UVM_LOW);
                    error = 1;
                end
                
                if(error != 1) begin
                    `uvm_info(get_full_name(), $sformatf("SERIAL DATA MATCHES"), UVM_LOW);
                end else begin
                    `uvm_info(get_full_name(), $sformatf("SERIAL DATA IS INCORRECT"), UVM_LOW);
                    `uvm_fatal(get_type_name(), $sformatf("ERROR"));
                end  
             end   
        end            
    endtask: compare_ser_trans
        
    virtual task compare_des_trans();
        des_transaction d_act_trans;
        if(d_act_trans_fifo.size != 0) begin
            d_act_trans = d_act_trans_fifo.pop_front();
            `uvm_info(get_full_name(), $sformatf("expected 8b = %b, actual 8b = %b ", exp_trans.in_data, d_act_trans.out_8b), UVM_LOW);
                
            assert (exp_trans.in_data == d_act_trans.out_8b) begin
                `uvm_info(get_full_name(), $sformatf("8b MATCHES"), UVM_LOW);
            end else begin
                `uvm_info(get_full_name(), $sformatf("8b INCORRECT"), UVM_LOW);
                error = 1;
                `uvm_fatal(get_type_name(), $sformatf("ERROR"));
            end
         end          
    endtask: compare_des_trans
    
    function void report_phase(uvm_phase phase);
        if(error == 0) begin
          $display("--------------------------------------------------");
          $display("------ INFO : TEST CASE PASSED -------------------");
          $display("--------------------------------------------------");
        end else begin
          $display("---------------------------------------------------");
          $display("------ ERROR : TEST CASE FAILED -------------------");
          $display("---------------------------------------------------");
        end
    endfunction: report_phase
    
endclass: serdes_scoreboard
    
`endif