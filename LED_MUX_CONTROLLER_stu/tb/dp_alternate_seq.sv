class dp_alternate_seq extends uvm_sequence#(dp_transaction);

  `uvm_object_utils(dp_alternate_seq)
   rand int iteration; 
   rand bit [14:0] addr_s;  
   rand int position; 
   rand int digits[0:5];
   rand bit even_digit;
   rand bit [19:0] error_s;
   rand int first_d;
   rand int second_d;
   rand int third_d;
   rand int fourth_d;
   rand int fifth_d;
   rand int sixth_d;

  constraint all_digits_unique {

    even_digit == 1;

  foreach (digits[i]) {
    if(i%2 == even_digit ) {
    digits[i] inside {[1:9]};
	} 
    else {
    digits[i] == 0 ;
	}
//	digits[i] == 0;	
  }
  
}
   constraint new_var{
	error_s%10== first_d;
	(error_s/10)%10== second_d;
	(error_s/100)%10== third_d;
	(error_s/1000)%10== fourth_d;
	(error_s/10000)%10== fifth_d;
	(error_s/100000)%10== sixth_d;
	if(even_digit) {
	first_d inside {[1:9]};
	second_d inside {0};
	third_d inside {[1:9]};
	fourth_d inside {0};
	fifth_d inside {[1:9]};
	sixth_d inside {0};
} else{
	first_d inside {0};
	second_d inside {[1:9]};
	third_d inside {0};
	fourth_d inside {[1:9]};
	fifth_d inside {0};
	sixth_d inside {[1:9]};
}


   }


   



  function new (string name = "");
    super.new(name);
    all_digits_unique.constraint_mode(0);
  endfunction

  task body;
    $display("iteration %d", iteration);
    repeat(iteration) begin
      req = dp_transaction::type_id::create("req");
      start_item(req);
      iteration.rand_mode(0);
      this.randomize();
      $display("DEBUG error_s %d", error_s);
      //if (!req.randomize() with {req.error_cnt == digits[0] + digits[1]*10 + digits[2]*100 +  digits[3]*1000 + digits[4]*10000 + digits[5]*100000;}) begin
	if(!req.randomize() with {req.error_cnt == error_s;})begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      



    end
  endtask: body

endclass: dp_alternate_seq
