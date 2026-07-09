class dp_base_sequence extends uvm_sequence #(dp_transaction);

  `uvm_object_utils(dp_base_sequence)
   rand int iteration; 
   rand bit [14:0] addr_s;  
   rand int error_s; 

  function new (string name = "");
    super.new(name);
  endfunction

  /*task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
       if (!req.randomize() with {req.error_cnt inside {[0:9]};}) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      

   end
  endtask: body */

  task body;
    // lower_nonzero();
    // higher_nonzero();
    // sweeping_nonzero();
    // alternate_nonzero();
    different();
  endtask: body

  //only bit 0-2 are non-zero, 3-5 are zero
  task lower_nonzero;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      //assert(req.randomize());
      if (!req.randomize() with {
	req.error_cnt inside {[111000:999000]}; //LED displays 111-999
        ((req.error_cnt % 10) != 0) && //ones is not zero
	(((req.error_cnt /10) % 10) != 0) && //tens
	(((req.error_cnt / 100) % 10) != 0);  //hundreds

        }) begin 
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
    end
  endtask: lower_nonzero

  //only bit 0-2 are zero, 3-5 are non-zero
  task higher_nonzero;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      //assert(req.randomize());
      if (!req.randomize() with {
	req.error_cnt inside {[0:999999]}; //LED displays 0-999999
        ((req.error_cnt %1000) == 0) && //lower 3 digits are zero
	(((req.error_cnt /1000) % 10) != 0) && //thousand
	(((req.error_cnt / 10000) % 10) != 0) &&  //ten thousand
	(((req.error_cnt / 100000) % 10) != 0); //hundred thousand

        }) begin 
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
    end
  endtask: higher_nonzero

  //only one digit is non-zero at a time, while other digits are zero
  task sweeping_nonzero;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      //assert(req.randomize());
      if (!req.randomize() with {
	req.error_cnt inside {[1:900000]}; //LED displays 1-900000
        // sum will be = 1 only since only one digit is non-zero
        (((req.error_cnt /100000) % 10 != 0) ? 1 : 0) +  //hundred thousands
	(((req.error_cnt /10000) % 10 != 0) ? 1 : 0) +  //ten thousands
	(((req.error_cnt /1000) % 10 != 0) ? 1 : 0) +  //thousands
	(((req.error_cnt /100) % 10 != 0) ? 1 : 0) +  //hundreds
	(((req.error_cnt /10) % 10 != 0) ? 1 : 0) +  //check tens is not equal to 0 or not
	(((req.error_cnt % 10) != 0) ? 1 : 0) == 1;
	
        }) begin 
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
    end
  endtask: sweeping_nonzero

  //zero-nonzero-zero...
  task alternate_nonzero;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      //assert(req.randomize());
      if (!req.randomize() with {
	req.error_cnt inside {[0:999999]}; //LED displays 0-999999
        
	//zero-nonzero-zero...
	( (((req.error_cnt /100000) % 10) == 0 ) && 
	  (((req.error_cnt /10000) % 10) != 0) &&
          (((req.error_cnt /1000) % 10) == 0 ) && 
	  (((req.error_cnt /100) % 10) != 0) &&
          (((req.error_cnt /10) % 10) == 0 ) && 
	  ((req.error_cnt % 10) != 0) 

        ) ||

	( (((req.error_cnt /100000) % 10) != 0 ) && 
	  (((req.error_cnt /10000) % 10) == 0) &&
          (((req.error_cnt /1000) % 10) != 0 ) && 
	  (((req.error_cnt /100) % 10) == 0) &&
          (((req.error_cnt /10) % 10)!= 0 ) && 
	  ((req.error_cnt % 10) == 0) 
        );

        }) begin 
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
    end
  endtask: alternate_nonzero


   //all 6 digits are different, no repeating
   task different;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      //assert(req.randomize());
      if (!req.randomize() with {
	req.error_cnt inside {[0:999999]}; //LED displays 0-999999
        //compare digit0 with others
        ((req.error_cnt % 10) != ((req.error_cnt /10) % 10)) &&
        ((req.error_cnt % 10) != ((req.error_cnt /100) % 10)) &&
	((req.error_cnt % 10) != ((req.error_cnt /1000) % 10)) &&
	((req.error_cnt % 10) != ((req.error_cnt /10000) % 10)) &&
	((req.error_cnt % 10) != ((req.error_cnt /100000) % 10)) &&

	//compare digit1 with others
	(((req.error_cnt /10) % 10) != ((req.error_cnt /100) % 10)) &&
	(((req.error_cnt /10) % 10) != ((req.error_cnt /1000) % 10)) &&
	(((req.error_cnt /10) % 10) != ((req.error_cnt /10000) % 10)) &&
	(((req.error_cnt /10) % 10) != ((req.error_cnt /100000) % 10)) &&

	//compare digit2 with others
	(((req.error_cnt /100) % 10) != ((req.error_cnt /1000) % 10)) &&
	(((req.error_cnt /100) % 10) != ((req.error_cnt /10000) % 10)) &&
	(((req.error_cnt /100) % 10) != ((req.error_cnt /100000) % 10)) &&

	
	//compare digit3 with others
	(((req.error_cnt /1000) % 10) != ((req.error_cnt /10000) % 10)) &&
	(((req.error_cnt /1000) % 10) != ((req.error_cnt /100000) % 10)) &&

        //compare digit4 with others
	(((req.error_cnt /10000) % 10) != ((req.error_cnt /100000) % 10));


        }) begin 
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      
    end
  endtask: different

endclass: dp_base_sequence
