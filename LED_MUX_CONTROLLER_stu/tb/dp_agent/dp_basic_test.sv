// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

 class dp_basic_test extends base_test;
    `uvm_component_utils(dp_basic_test)
    
    //create a handle for your seq: 
    dp_base_sequence myseq;


    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    endfunction
   
    function void connect_phase(uvm_phase phase);
    endfunction
   
   
  
   function void end_of_elaboration_phase(uvm_phase phase);
   endfunction 
   
    
    task run_phase(uvm_phase phase);
   
      // Set the action for UVM_ERROR to UVM_DISPLAY and UVM_LOG 
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "is running!",UVM_LOW)
      
      //start a sequence here: e/g:
      //   mySlvseq=mySlv_sequence::type_id::create("mySlvseq",this);
      //   mySlvseq.randomize();
      //   mySlvseq.start(env.my_slv_agent.sequencer);// point to the slave agent.
      myseq=dp_base_sequence::type_id::create("myseq",this);
      myseq.randomize() with { iteration  == 10;} ;
      myseq.start(env.agent1.sequencer);



      phase.drop_objection(this);
      phase.phase_done.set_drain_time(this,5000ns);
 
    endtask

  endclass
