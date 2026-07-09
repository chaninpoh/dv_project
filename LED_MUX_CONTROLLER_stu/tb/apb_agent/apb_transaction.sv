class apb_transaction extends uvm_sequence_item;
 typedef enum {NULL, READ,WRITE} op_t;


 rand int unsigned delay;
 int wait_cycle;

 rand bit [31:0] data;
 rand bit [31:0] addr;
 rand op_t op; 
 rand bit slverr;


  `uvm_object_utils_begin(apb_transaction) //TUTORIAL 1
   `uvm_field_int (delay,UVM_ALL_ON| UVM_NOCOMPARE);
   `uvm_field_int (wait_cycle,UVM_ALL_ON| UVM_NOCOMPARE);
   `uvm_field_int (data,UVM_ALL_ON);
   `uvm_field_int (addr,UVM_ALL_ON);
   `uvm_field_enum (op_t, op,UVM_ALL_ON | UVM_NOCOMPARE);
   `uvm_field_int (slverr,UVM_ALL_ON);
  `uvm_object_utils_end
  //use uvm_object_utils_begin and uvm_object_utils_end 
  

  
  //add your contraints here.//TUTORIAL 1
  constraint c {
	delay == 0; 
  } 
  
  
  
  
  function new (string name = "");
    super.new(name);
    //seg_mux_cg = new();
  endfunction
      
        
   function sample ();
	//seg_mux_cg.sample();
endfunction 
      
      

endclass: apb_transaction
