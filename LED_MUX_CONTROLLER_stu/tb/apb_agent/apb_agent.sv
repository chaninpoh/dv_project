// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


  class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    
   virtual apb_if dut_vif;
    
    apb_driver driver;
    apb_monitor monitor;
    uvm_sequencer#(apb_transaction) sequencer;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      `uvm_info(get_type_name(), "Build phase for apb_agent", UVM_LOW)
      if(is_active == UVM_ACTIVE) begin
       sequencer =
	 uvm_sequencer#(apb_transaction)::type_id::create("sequencer", this);
       driver = apb_driver ::type_id::create("driver", this);
      end 
       monitor = apb_monitor ::type_id::create("monitor", this);
	

    endfunction    
    
    function void connect_phase(uvm_phase phase);
      if (is_active == UVM_ACTIVE)
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    
  endclass
