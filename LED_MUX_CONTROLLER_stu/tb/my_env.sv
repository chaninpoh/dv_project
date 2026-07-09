// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


  class my_env extends uvm_env;
    `uvm_component_utils(my_env)
   
    
   //__TB__//dp_agent agent1;
   //handle for other agents 


    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      `uvm_info(get_type_name, "This is my env", UVM_LOW)
      //__TB__//agent1 = dp_agent::type_id::create("agent1", this);

      //__TB__// add passive agent
      //__TB__// add scoreboard


    endfunction
    
    function void connect_phase(uvm_phase phase);
   //connection agent scoreboard to the aep_f2s_s2f port
   //__TB__//Connect to the scoreboard
   // agent1.monitor.analysis_port.connect(top_scoreboard.aep_dp);
    endfunction
    
    

 endclass
