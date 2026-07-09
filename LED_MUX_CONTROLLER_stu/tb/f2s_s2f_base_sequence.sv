class f2s_s2f_base_sequence extends uvm_sequence#(f2s_s2f_transaction);

  `uvm_object_utils(f2s_s2f_base_sequence)
   rand int iteration; 
   rand bit [14:0] addr_s;  
  
  
  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      this.randomize(addr_s); // with {addr_s == iteration;};// with {addr_s == 0;}; 
      req = f2s_s2f_transaction::type_id::create("req");
      //WRITE TRANSACTION
      start_item(req);
      if (!req.randomize() with  {req.op == WRITE; req.addr == addr_s; }) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
      //READ TRANSACTION
      start_item(req);
      if (!req.randomize() with  {req.op == READ; req.addr == addr_s; }) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);



    end
  endtask: body

endclass: f2s_s2f_base_sequence
