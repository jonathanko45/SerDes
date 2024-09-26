`ifndef SER_ENV_PKG
`define SER_ENV_PKG

package ser_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

   // importing packages : agent,ref model, register ...
   import ser_agent_pkg::*;
   import ser_ref_model_pkg::*;

   // include top env files 
  `include "ser_coverage.sv"
  `include "ser_scoreboard.sv"
  `include "ser_environment.sv"
    
endpackage

`endif