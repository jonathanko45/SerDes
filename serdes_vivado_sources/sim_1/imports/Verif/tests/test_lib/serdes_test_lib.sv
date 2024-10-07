`ifndef SERDES_TEST_LIB
`define SERDES_TEST_LIB

package serdes_test_lib;
  import uvm_pkg::*;
 `include "uvm_macros.svh"

 import serdes_env_pkg::*;
 import serdes_sequence_lib::*;

 // including ser test list
 `include "serdes_base_test.sv"    

endpackage

`endif