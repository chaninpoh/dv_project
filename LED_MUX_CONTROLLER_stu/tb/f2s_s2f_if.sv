// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

interface f2s_s2f_if(input clk, reset);

  logic [15:0] f2s_data;
  logic [14:0] f_addr;
  logic [15:0] s2f_data; 
  logic f2s_data_valid;
  logic s2f_data_valid;
  logic rw_sig; //header_valid
  logic rw_en_sig;
  logic ready; 
  
  
endinterface
