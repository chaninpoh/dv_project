// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


  class dp_agent extends uvm_agent;
    `uvm_component_utils(dp_agent)
    
   virtual dp_if dut_vif;
    dp_driver driver;
    dp_monitor monitor;
    uvm_sequencer#(dp_transaction) sequencer;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      `uvm_info(get_type_name(),"Printing from Agent", UVM_LOW);
     
     /* 
      // get VIF from env or test
      if(!uvm_config_db#(virtual dp_if)::get(this, "", "vif",dut_vif))
        `uvm_fatal("NOVIF", "dp_if not set in config DB")
      // pass VIF to driver
      uvm_config_db#(virtual dp_if)::set(this, "driver", "vif", dut_vif);
      // pass VIF to monitor
      uvm_config_db#(virtual dp_if)::set(this, "monitor", "vif", dut_vif);
      */

      driver = dp_driver ::type_id::create("driver", this);
      monitor = dp_monitor ::type_id::create("monitor", this);
      sequencer = uvm_sequencer#(dp_transaction)::type_id::create("sequencer", this);

    endfunction    
    
        // in set_if method, we connect the if to the driver.
    function void assign_if(virtual dp_if vif);
      this.dut_vif = vif; 
      driver.dut_vif = dut_vif; //connect next level
    endfunction
    
    // In UVM connect phase, we connect the sequencer to the driver.
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    
  endclass
