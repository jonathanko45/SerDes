`ifndef SER_DRIVER
`define SER_DRIVER

class ser_driver extends uvm_driver #(ser_transaction);
    virtual interface serializer_if s_vif;
    
    `uvm_component_utils(ser_driver)
    
    uvm_analysis_port#(ser_transaction) drv2rm_port;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual serializer_if)::get(this, "", "ser_intf", s_vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".s_vif"})
        drv2rm_port = new("drv2rm_port", this);
        `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        reset();
        forever begin
            seq_item_port.get_next_item(req);
            drive();
            `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
            req.print();
            repeat (2) @(s_vif.dr_cb);
            @(s_vif.rc_cb); //one of each so monitor synchs with ref model
            $cast(rsp, req.clone()); //making clone of transaction to send to reference model
            rsp.set_id_info(req);
            drv2rm_port.write(rsp);
            seq_item_port.item_done();
            seq_item_port.put(rsp);
        end
    endtask: run_phase
    
    virtual task reset();
         `uvm_info(get_type_name(), "Resetting Serializer Signals", UVM_LOW);
         s_vif.dr_cb.in_data <= 8'b00000000;
         s_vif.dr_cb.in_RD <= 2'sb11;
         s_vif.dr_cb.rst_n <= 0;
         //@(s_vif.dr_cb);
    endtask: reset
    
    virtual task drive();
        @(s_vif.dr_cb);
        wait(!s_vif.reset);
        @(s_vif.dr_cb);
        s_vif.dr_cb.rst_n <= 1'b1;
        s_vif.dr_cb.in_data <= req.in_data;
        s_vif.dr_cb.in_RD <= req.in_RD;
    endtask: drive
     
endclass: ser_driver

`endif
        
    