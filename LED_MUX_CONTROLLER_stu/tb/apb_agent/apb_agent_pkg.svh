package apb_agent_pkg;
     import uvm_pkg::*;

parameter REFRESH_RATE_IN_CYCLES = 1002;

`include "apb_transaction.sv"
`include "apb_driver.sv" 
`include "apb_monitor.sv"
`include "apb_agent.sv"


  
endpackage
