class apb_base_sequence extends uvm_sequence#(apb_transaction);

  `uvm_object_utils(apb_base_sequence)
   rand bit [31:0] addr_s;  
   rand bit [31:0] read_data;	



  constraint C {
     //   position dist {[0:100]:=70, [1000:100000]:=30}; 
  }


  function new (string name = "");
    super.new(name);
  endfunction

  task body;
	write_apb(32'h4000,32'h1);
	read_apb(32'h4000,read_data);
	`uvm_info(get_type_name, $sformatf("READ DATA is %x",read_data), UVM_LOW)

	read_apb(32'h4004,read_data);
	while (read_data != 32'h1) begin
		read_apb(32'h4004,read_data);
		#10ns;
	end
        //write to scratch pad 
	write_apb(32'h4008,32'hABCD_EF12);	
	read_apb(32'h4008,read_data);
	if(read_data != 32'hABCD_EF12) begin
		`uvm_error(get_type_name, "ERROR READBACK FROM SCRATCHPAD")
	end else  
		`uvm_info(get_type_name, "SCRATCH PAD COMPARE PASS",UVM_LOW)

      $display ("Finish");
  endtask: body

  virtual task write_apb( input logic [31:0] addr_s, input logic [31:0] pwdata);
      req = apb_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {req.op == apb_transaction::WRITE;req.addr == addr_s;req.data == pwdata;}) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      req = null;
  endtask

  virtual task read_apb(input logic [31:0] addr_s, output logic [31:0] prdata);
      req = apb_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {req.op == apb_transaction::READ;req.addr == addr_s;}) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end
      finish_item(req);
      get_response(rsp);
      prdata = rsp.data; 
      req = null;
  endtask
 




endclass: apb_base_sequence
