class dp_transaction extends uvm_sequence_item;

//__TB__//
  rand int delay;

  
  `uvm_object_utils_begin(dp_transaction) //TUTORIAL 1
  `uvm_field_int (delay,UVM_ALL_ON| UVM_NOCOMPARE);
   //__TB__//add uvm_object_utils for each of your variables.
  
  `uvm_object_utils_end


  constraint c {
	delay == REFRESH_RATE_IN_CYCLES; 
  } 
  
  
  
  function new (string name = "");
    super.new(name);
  //__COV__  seg_mux_cg = new();
  endfunction
      
        
   function sample ();
  //__COV__	seg_mux_cg.sample();
endfunction 
      
      

endclass: dp_transaction
