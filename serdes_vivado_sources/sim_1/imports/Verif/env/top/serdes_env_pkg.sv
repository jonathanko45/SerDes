`ifndef SERDES_ENV_PKG
`define SERDES_ENV_PKG

package serdes_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

   // importing packages : agent,ref model, register ...
   import serdes_agent_pkg::*;
   import serdes_ref_model_pkg::*;

   // include top env files 
  `include "serdes_coverage.sv"
  `include "serdes_scoreboard.sv"
  `include "serdes_env.sv"
    
endpackage

`endif