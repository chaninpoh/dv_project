// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

interface apb_if#(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH= 32)(input clk, rst_n);
  

 logic [ADDR_WIDTH-1:0] paddr;                         //Peripheral address bus
 logic pwrite;                                         //Peripheral transfer direction
 logic psel;                                           //Peripheral slave select
 logic penable;                                        //Peripheral enable
 logic [DATA_WIDTH-1:0] pwdata;                        //Peripheral write data bus

 logic [DATA_WIDTH-1:0] prdata;                       //Peripheral read data bus
 logic pready;                                        //Read signal. The slave issues this signal to extend an APB transfer.
 logic pslverr;   


 modport master (
	input prdata, pready,pslverr,
	output paddr,pwrite,psel,penable,pwdata
);
 modport slave (
	input paddr,pwrite,psel,penable,pwdata,
	output prdata, pready,pslverr
);







endinterface
