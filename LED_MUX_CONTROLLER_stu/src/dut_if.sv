// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

interface dut_if(input clk, reset);

  logic [31:0] data_in;
  logic hdr_vld; //header_valid
  logic data_valid;
  logic ready; 
  
  
endinterface