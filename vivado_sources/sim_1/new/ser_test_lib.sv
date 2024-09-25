`ifndef SER_TEST_LIB
`define SER_TEST_LIB

package ser_test_lib;
  import uvm_pkg::*;
 `include "uvm_macros.svh"

 import ser_env_pkg::*;
 import ser_sequence_lib::*;

 // including ser test list
 `include "ser_base_test.sv"    

endpackage

`endif