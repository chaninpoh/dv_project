package dp_agent_pkg;
     import uvm_pkg::*;

parameter REFRESH_RATE_IN_CYCLES = 1002;
parameter PROP_DELAY = 80; //propagation delay

`include "dp_transaction.sv"
`include "dp_driver.sv" 
`include "dp_monitor.sv"
`include "dp_agent.sv"


  
endpackage
