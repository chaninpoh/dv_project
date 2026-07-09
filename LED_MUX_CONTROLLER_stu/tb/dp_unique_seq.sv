class dp_unique_seq extends uvm_sequence#(dp_transaction);

  `uvm_object_utils(dp_unique_seq)
   rand int iteration; 
   rand bit [14:0] addr_s;  
   rand int position; 
   rand int digits[0:5];


  constraint all_digits_unique {

  foreach (digits[i]) {

    digits[i] inside {[0:9]};

  }
  foreach (digits[i]) {
    foreach (digits[j]) {
      if (i != j) {
	      digits[i] != digits[j]; 
    }
  }

}
}



  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
	this.randomize(digits);
      if (!req.randomize() with {req.error_cnt == digits[0] + digits[1]*10 + digits[2]*100 +  digits[3]*1000 + digits[4]*10000 + digits[5]*100000;}) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      



    end
  endtask: body

endclass: dp_unique_seq
