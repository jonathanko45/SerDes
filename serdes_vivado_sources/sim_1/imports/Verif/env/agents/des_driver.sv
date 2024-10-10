`ifndef DES_DRIVER
`define DES_DRIVER

class des_driver extends uvm_driver #(des_transaction);
    virtual interface deserializer_if d_vif;
    
    des_transaction m_item;
    
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
            seq_item_port.get_next_item(m_item);
            drive();
            `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER to DESERIALIZER"), UVM_LOW);
            m_item.print();
            seq_item_port.item_done();
        end
    endtask: run_phase
    
    virtual task reset();
        `uvm_info(get_type_name(), "Resetting Deserializer Signals", UVM_LOW);
        d_vif.dr_cb_fast.in_data <= 0;
        d_vif.dr_cb_fast.rst_n <= 0;
        
        d_vif.dr_cb_fast.wrst_n <= 0;
        d_vif.dr_cb_fast.w_en <= 0;
        d_vif.dr_cb_fast.rrst_n <= 0;
        d_vif.dr_cb_fast.r_en <= 0;
        //`uvm_fatal(get_full_name(), $sformatf("REACHED reset()"));
    endtask: reset
    
    virtual task drive();
        //has waits and sends data one bit at a time
        @(d_vif.dr_cb_fast);
        wait(!d_vif.reset);
        @(d_vif.dr_cb_fast);
        d_vif.dr_cb_fast.rst_n <= 1'b1;
        d_vif.dr_cb_fast.wrst_n <= 1'b1;
        
        //need to figure out how this works. i think because its clocking block I dont need to alternate it?
        d_vif.dr_cb_fast.w_en <= 1'b1; 
        
        for(int i = 0; i < 10; i++) begin
            d_vif.dr_cb_fast.in_data <= m_item.in_10b[i];
            @(d_vif.dr_cb_fast);
        end
        
        //now need to wait a bit until fifo is full and then enable read option
        //montior in passive slave needs to wait until these are enabled before reading
        //@(d_vif.dr_cb);
        /*
        d_vif.dr_cb_fast.rrst_n <= 1'b1;
        d_vif.dr_cb_fast.r_en <= 1'b1;
        */
    endtask: drive
    
endclass: des_driver

`endif
