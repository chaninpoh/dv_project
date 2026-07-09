class base_sequence extends uvm_sequence#(f2s_s2f_transaction);

  `uvm_object_utils(base_sequence)
   rand int iteration; 
  
  
  
  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = f2s_s2f_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize()) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      req.print();
      finish_item(req);
    end
  endtask: body

endclass: base_sequence
