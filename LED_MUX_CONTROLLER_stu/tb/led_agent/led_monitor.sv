// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class led_monitor extends uvm_monitor;

  `uvm_component_utils(led_monitor)

  virtual led_if dut_vif;
  uvm_analysis_port#(led_transaction) analysis_port;
  led_transaction collected_trans; 
  int local_length; 
  int local_addr; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
   
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for led_monitor", UVM_LOW)
    // Get interface reference from config database
     analysis_port = new("analysis_port",this); 
  if(!uvm_config_db#(virtual led_if)::get(this, "", "dut_vif", dut_vif)) begin
     `uvm_error("", "uvm_config_db::get failed")
  end
 
    
  endfunction 

  task run_phase(uvm_phase phase);
    collected_trans=led_transaction::type_id::create("collected_trans",this);
    // Now drive normal traffic
    forever begin
      @(posedge dut_vif.clk);
      monitor_item();
    end
  endtask
  
  task monitor_item();
    for(int i = 0; i < 6; i ++ ) begin	  
    @(posedge dut_vif.clk iff ~dut_vif.sel_out[i]);//start capturing
    $display("SEL_OUT %b", collected_trans.sel_out);
    collected_trans.seg_out <= dut_vif.seg_out;
    collected_trans.sel_out <= dut_vif.sel_out; 

    repeat(80)@(posedge dut_vif.clk); 
//  $display("Print from Monitor : ");
    `uvm_info(get_full_name(),"this is what i capture",UVM_LOW);
    collected_trans.print();      
    analysis_port.write(collected_trans); //send to scoreboard
    end 
    
    
    
  endtask 
  
  

endclass: led_monitor
