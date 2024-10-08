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
            seq_item_port.item_done();
        end
    endtask: run_phase
    
    virtual task reset();
        `uvm_fatal(get_full_name(), $sformatf("REACHED reset()"));
    endtask: reset
    
    virtual task drive();
        //has waits and sends data one bit at a time
    endtask: drive
endclass: des_driver

`endif
