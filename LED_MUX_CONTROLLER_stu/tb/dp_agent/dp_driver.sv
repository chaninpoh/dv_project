// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class dp_driver extends uvm_driver #(dp_transaction);

  `uvm_component_utils(dp_driver)

  virtual dp_if dut_vif;
  int SLAVE_IF = 0;
  int wait_cycles = 1002; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual dp_if)::get(this, "", "dut_vif", dut_vif)) begin
       `uvm_error("", "uvm_config_db::get failed")
    end
    
    
  endfunction 

  task run_phase(uvm_phase phase);
    wait(dut_vif.reset==1);
  
    // Now drive normal traffic
    forever begin
      seq_item_port.get_next_item(req);
      drive_item();
      seq_item_port.item_done();
      seq_item_port.put_response(req);
    end
  endtask
  
  virtual task drive_item();
	req.print();
  //__TB__//implement your driver here

  //__TB__// add a print statement here
  endtask 
  

endclass: dp_driver
