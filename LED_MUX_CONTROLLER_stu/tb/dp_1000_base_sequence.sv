class dp_1000_base_sequence extends uvm_sequence#(dp_transaction);

  `uvm_object_utils(dp_1000_base_sequence)
   rand int iteration; 
   rand bit [14:0] addr_s;  
   rand int error_s; 
   rand int position; 

  constraint C {
	error_s inside {[1:9]};
//	position inside {1, 10,100,1000,10000,100000};
//        position dist {[0:100i]:=1, [1000:100000]:=0}; 

  }


  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
	this.randomize(error_s);
	this.randomize(position);
      if (!req.randomize() with {req.error_cnt > 0 ; req.error_cnt <5000; }) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      



    end
  endtask: body

endclass: dp_1000_base_sequence
