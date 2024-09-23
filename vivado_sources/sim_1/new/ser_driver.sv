`ifndef SER_DRIVER
`define SER_DRIVER

class ser_driver extends uvm_driver #(ser_transaction);
    virtual interface serializer_if vif;
    
    `uvm_component_utils(ser_driver)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if(!uvm_config_db#(virtual serializer_if)::get(this, "", "in_intf", vif))
            `uvm_fatal("NOVIF", {"Virtual Interface must be set for: ", get_full_name(), ".vif"})
            `uvm_info(get_full_name(), "Build Stage Complete", UVM_LOW)
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        fork //runs tasks in parallel
            reset();
            get_and_drive();
        join
    endtask: run_phase
    
    virtual task reset();
        forever begin
            @(negedge vif.rst_n);
            `uvm_info(get_type_name(), "Resetting Signals", UVM_LOW)
            vif.ser_enable = 0;
            vif.in_data = 0;
            vif.out_data = 0;
            vif.out_10b = 0;
        end
    endtask: reset
    
    virtual task get_and_drive();
        forever begin
            while(vif.rst_n != 1'b0) begin
                seq_item_port.get_next_item(req);
                drive_packet(req);
                seq_item_port.item_done();
             end
         end
    endtask: get_and_drive
    
    //this is my drive packet that needs to run serializer
    virtual task drive_packet(ser_transaction pkt); 
        vif.ser_enable = 1'b0;
        repeat(pkt.delay) @(posedge vif.clk);
        vif.ser_enable = pkt.ser_enable;
        vif.in_data = pkt.in_data;
        @(posedge vif.clk);
        vif.ser_enable = 1'b0;
    endtask: drive_packet
     
endclass: ser_driver

`endif
        
    