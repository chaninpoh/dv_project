// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

 class my_test extends base_test;
    `uvm_component_utils(my_test)
    
    //create a handle for your seq: 
   //__TB__//dp_base_sequence myseq;


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
   
      // We raise objection to keep the test from completing
      phase.raise_objection(this); // to raise a flag to say sequence is running
      `uvm_info(get_type_name(), "My test is running!",UVM_LOW)
      `uvm_info(get_type_name(), "Run my_test",UVM_LOW)  
      //start a sequence here: e/g:
//__TB__//
/*   myseq=dp_base_sequence::type_id::create("myseq",this);
     myseq.randomize() with {iteration == 1;};
     myseq.start(env.agent1.sequencer);// point to the slave agent.
*/

      phase.drop_objection(this); //to drop the flag you have raised before
      phase.phase_done.set_drain_time(this,10000ns);
 
    endtask

  endclass
