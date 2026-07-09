// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  virtual apb_if dut_vif;
  uvm_analysis_port#(apb_transaction) analysis_port;
  apb_transaction collected_trans; 
  int local_length; 
  int local_addr; 
  int prev_value;
   uvm_active_passive_enum is_active;

  function new(string name, uvm_component parent);
    super.new(name, parent);
   
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for apb_monitor", UVM_LOW)
    // Get interface reference from config database
     analysis_port = new("analysis_port",this); 
  if(!uvm_config_db#(virtual apb_if)::get(this, "", "dut_vif", dut_vif)) begin
     `uvm_error("", "uvm_config_db::get failed")
  end
 
    
  endfunction 

  task run_phase(uvm_phase phase);
    collected_trans=apb_transaction::type_id::create("collected_trans",this);
    // Now drive normal traffic
    forever begin
	 monitor_act_item();
    end
  endtask
  
  task monitor_act_item();
      @(posedge dut_vif.clk iff dut_vif.psel === 1'b1 && dut_vif.penable ===1'b1 && dut_vif.pready === 1'b1);
      if(dut_vif.pwrite === 1'b1) begin
	collected_trans.op = apb_transaction::WRITE;
	collected_trans.addr= dut_vif.paddr;
	collected_trans.data = dut_vif.pwdata;
      end else begin
	collected_trans.op = apb_transaction::READ;
	collected_trans.addr = dut_vif.paddr;
	collected_trans.data = dut_vif.prdata;
	collected_trans.slverr = dut_vif.pslverr;
      end
     	`uvm_info(get_type_name(),"Printing...",UVM_LOW) 
         collected_trans.print();
	 analysis_port.write(collected_trans);
  endtask	  
  
  
  

endclass: apb_monitor
