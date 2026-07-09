class virtual_base_sequence extends uvm_sequence;

  `uvm_object_utils(virtual_base_sequence)
 `uvm_declare_p_sequencer(virtual_sequencer)

 dp_transaction obj1;
  //add another sequence/sequence_item
 
 
 
   rand int iteration; 
   rand bit [14:0] addr_s;  
   rand int error_s; 
  
  function new (string name = "");
    super.new(name);
  endfunction

  task body;

   fork 

    repeat(iteration) begin
      obj1 = dp_transaction::type_id::create("obj1");
     `uvm_do_on_with(obj1, p_sequencer.m_dp_seqr, {obj1.error_cnt inside {[1:999999]};}) 
     get_response(rsp);
    end
    begin
    	//start a sequence from APB
    
    end 
   join
	



  endtask: body

endclass: virtual_base_sequence
