// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    
   
  //__TB__//
  // Instantiate enviroment 
      my_env env; 
    uvm_factory factory;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      //__TB__// "new-ed the class instance with create method"
      env = my_env::type_id::create("env", this);
      //__TB__// 
      // set dp agent (uvm active)
      uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent1.monitor", "is_active", UVM_ACTIVE);
      //__TB__//
      // set dp agent (uvm passive)
      uvm_config_db#(uvm_active_passive_enum)::set(this, "env.psv_agent1.monitor", "is_active", UVM_PASSIVE);
    endfunction
   
    function void connect_phase(uvm_phase phase);
    endfunction
   
   
  
   function void end_of_elaboration_phase(uvm_phase phase);
     factory = uvm_factory::get();// get the factory instance handle. 
      factory.print();
      uvm_top.print_topology();
   endfunction 
   
    
    task run_phase(uvm_phase phase);
   
      // Set the action for UVM_ERROR to UVM_DISPLAY and UVM_LOG 
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "Base Sequence!",UVM_LOW)
     
      //__TB__//add a `uvm_info


      phase.drop_objection(this);
      phase.phase_done.set_drain_time(this,5000ns);
 
    endtask

  endclass
