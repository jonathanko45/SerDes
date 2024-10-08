`ifndef SER_AGENT_PKG
`define SER_AGENT_PKG

package ser_agent_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh"
    
   typedef uvm_object_string_pool #(uvm_queue#(int)) uvm_queue_pool;
    
   // include Agent components : driver,monitor,sequencer
  `include "ser_transaction.sv"
  `include "ser_sequencer.sv"
  `include "ser_driver.sv"
  `include "ser_monitor.sv"
  `include "ser_agent.sv"

endpackage

`endif
