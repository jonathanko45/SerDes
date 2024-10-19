`ifndef DES_DRIVER
`define DES_DRIVER

class des_driver extends uvm_driver #(des_transaction);
    virtual interface deserializer_if d_vif;
    
    des_transaction slave_req;
    
    `uvm_component_utils(des_driver)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual deserializer_if)::get(this, "", "des_intf", d_vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".d_vif"})
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        reset();
        forever begin
            seq_item_port.get_next_item(slave_req);
            drive();
            seq_item_port.item_done();
        end
    endtask: run_phase
    
    virtual task reset();
        `uvm_info(get_type_name(), "Resetting Deserializer Signals", UVM_LOW);
        d_vif.dr_cb_fast.in_data <= 0;
        d_vif.dr_cb_fast.rst_n <= 0;        
        d_vif.dr_cb_fast.wrst_n <= 0;
        d_vif.dr_cb_fast.w_en <= 0;
        d_vif.dr_cb.rrst_n <= 0;
        d_vif.dr_cb.r_en <= 0;
    endtask: reset
    
    virtual task drive();
        d_vif.dr_cb_fast.rst_n <= 1'b1;
        @(d_vif.dr_cb_fast);
        d_vif.dr_cb_fast.wrst_n <= 1'b1;
        @(d_vif.dr_cb_fast);

        drive_write(0, 8);

        repeat(2) @(d_vif.dr_cb);
        d_vif.dr_cb.rrst_n <= 1'b1;
        repeat(3) @(d_vif.dr_cb);
        
        drive_read();
        
        for(int i = 8; i < 10; i++) begin
            d_vif.r_en <= 1'b1;
            @(d_vif.dr_cb_fast);
            
            drive_write(i, i+1);

            @(d_vif.dr_cb);
            d_vif.r_en <= 1'b0;
            @(d_vif.dr_cb);
        end
        
        repeat(7) drive_read();

        d_vif.dr_cb_fast.wrst_n <= 1'b0;
        d_vif.dr_cb.rrst_n <= 1'b0;
    endtask: drive
    
    virtual task drive_write(int x, y);
        for(int i = x; i < y; i++) begin
            d_vif.dr_cb_fast.w_en <= 1'b1; 
            d_vif.dr_cb_fast.in_data <= slave_req.in_10b[i];
            @(d_vif.dr_cb_fast);
            d_vif.dr_cb_fast.w_en <= 1'b0;
            @(d_vif.dr_cb_fast);
        end
    endtask: drive_write
    
    virtual task drive_read();
        d_vif.r_en <= 1'b1;
        @(d_vif.dr_cb);
        d_vif.r_en <= 1'b0;
        @(d_vif.dr_cb);
    endtask: drive_read
    
endclass: des_driver

`endif
