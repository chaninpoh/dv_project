// Scoreboard + analysis imp declarations (must live in a package for VCS)
package led_tb_pkg;

  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import led_agent_pkg::*;

  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_apb)
  `uvm_analysis_imp_decl(_led)

  `include "led_scoreboard.sv"

endpackage
