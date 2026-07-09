// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


  class led_agent extends uvm_agent;
    `uvm_component_utils(led_agent)
    
   virtual led_if dut_vif;
    
    led_driver driver;
    led_monitor monitor;
    uvm_sequencer#(led_transaction) sequencer;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase for led_agent", UVM_LOW)
      if(!uvm_config_db#(uvm_active_passive_enum) :: get(this, "", "is_active", is_active) ) begin
	`uvm_error("", "uvm_config_db: :get failed passive")
      end

      monitor = led_monitor ::type_id::create("monitor", this);
      if(is_active== UVM_ACTIVE ) begin
      driver = led_driver ::type_id::create("driver", this);
      sequencer =
        uvm_sequencer#(led_transaction)::type_id::create("sequencer", this);
      end
    endfunction    
    
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) 
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    
  endclass
