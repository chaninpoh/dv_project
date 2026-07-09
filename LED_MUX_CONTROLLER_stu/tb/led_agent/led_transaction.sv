// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class led_transaction extends uvm_sequence_item;

  
  rand bit [7:0] seg_out;
  rand bit [5:0] sel_out;


  rand int unsigned probt; //probability, use in SLAVE_IF only 


  
  `uvm_object_utils_begin(led_transaction) //TUTORIAL 1
  `uvm_field_int (seg_out,UVM_ALL_ON | UVM_NOCOMPARE);
  `uvm_field_int (sel_out,UVM_ALL_ON| UVM_NOCOMPARE | UVM_BIN);
  `uvm_object_utils_end
  //use uvm_object_utils_begin and uvm_object_utils_end 
  
  
  
  function new (string name = "");
    super.new(name);
  endfunction
	
function sample();
endfunction	
      
      
      

endclass: led_transaction
