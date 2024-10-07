`ifndef SERDES_SEQUENCE_LIB
`define SERDES_SEQUENCE_LIB

package serdes_sequence_lib;
   
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import serdes_agent_pkg::*;
    import serdes_env_pkg::*;
    
    //including ser test list
    `include "ser_basic_sequence.sv"
    `include "des_slave_sequence.sv"

    
endpackage

`endif


