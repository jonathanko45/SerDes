`ifndef SERDES_AGENT_PKG
`define SERDES_AGENT_PKG

package serdes_agent_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh"
    
   typedef uvm_object_string_pool #(uvm_queue#(int)) uvm_queue_pool;
    
   // include Agent components : driver,monitor,sequencer
  `include "ser_transaction.sv"
  `include "ser_sequencer.sv"
  `include "ser_driver.sv"
  `include "ser_monitor.sv"
  `include "ser_agent.sv"
  
  //des components (reactive slave)
  `include "des_transaction.sv"
  `include "des_monitor.sv"
  `include "des_driver.sv"
  `include "des_sequencer.sv"
  `include "des_agent.sv"
  
  //des components (passive slave)
  `include "des_monitor_p.sv"
  `include "des_agent_p.sv"

endpackage

`endif
