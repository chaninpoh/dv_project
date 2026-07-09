// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class dp_monitor extends uvm_monitor;

  `uvm_component_utils(dp_monitor)

  virtual dp_if dut_vif;
  uvm_analysis_port#(dp_transaction) analysis_port;
  dp_transaction collected_trans; 
  int local_length; 
  int local_addr; 
   uvm_active_passive_enum is_active;

  function new(string name, uvm_component parent);
    super.new(name, parent);
   
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
     analysis_port = new("analysis_port",this); 
  if(!uvm_config_db#(virtual dp_if)::get(this, "", "dut_vif", dut_vif)) begin
     `uvm_error("", "uvm_config_db::get failed")
  end
  //RETRIEVE is_active
  if(!uvm_config_db#(uvm_active_passive_enum) :: get(this, "", "is_active", is_active) ) begin
        `uvm_error("", "uvm_config_db: :get failed passive")
  end
 
    
  endfunction 

  task run_phase(uvm_phase phase);
    collected_trans=dp_transaction::type_id::create("collected_trans",this);
    // Now drive normal traffic
    forever begin
//      @(posedge dut_vif.clk iff ~dut_vif.reset);
      if(is_active == UVM_ACTIVE)
	 monitor_act_item();
      else 
      	 monitor_psv_item();
    end
  endtask
  
  task monitor_act_item();
    @(posedge dut_vif.clk iff ~dut_vif.reset);//start capturing
	//TB//Capture Active Item here

    collected_trans.print();
    analysis_port.write(collected_trans); //send to scoreboard
  endtask	  

  task monitor_psv_item();
    @(posedge dut_vif.clk iff ~dut_vif.reset);//start capturing
 	//Capture your Passive Item here

    collected_trans.print();
    analysis_port.write(collected_trans); //send to scoreboard    
  endtask 
  
  

endclass: dp_monitor
