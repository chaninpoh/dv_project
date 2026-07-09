// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class apb_driver extends uvm_driver #(apb_transaction);

  `uvm_component_utils(apb_driver)

  virtual apb_if dut_vif;
  int SLAVE_IF = 0; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "dut_vif", dut_vif)) begin
       `uvm_error("", "uvm_config_db::get failed")
    end
    
    
  endfunction 

  task run_phase(uvm_phase phase);
    // Now drive normal traffic
    wait(dut_vif.rst_n == 1);
    forever begin
      seq_item_port.get_next_item(req);
      drive_item();
      seq_item_port.item_done();
      seq_item_port.put_response(req);
    end
  endtask
  
  virtual task drive_item();
     req.print();
  //implement your driver here
  if(req.op == apb_transaction :: WRITE) begin
     @(posedge dut_vif.clk);
     dut_vif.paddr <= req.addr;
     dut_vif.pwdata <= req.data;
     dut_vif.pwrite<=1'b1;
     dut_vif.psel<=1'b1;
     dut_vif.penable <= 1'b0;
     do begin
        @(posedge dut_vif.clk)
//        $display("in while loop");
        dut_vif.penable <= 1'b1;
     end while ( dut_vif.pready === 0);
     dut_vif.paddr<= 32'h0;
     dut_vif.pwrite<=1'b0;
     dut_vif.psel<=1'b0;
  end else begin
     @(posedge dut_vif.clk);
     dut_vif.pwrite<=1'b0;
     dut_vif.psel<=1'b1;
     dut_vif.penable <= 1'b0;
     dut_vif.paddr<= req.addr;
     do begin
	@(posedge dut_vif.clk)
//	$display("in while loop");
	dut_vif.penable <= 1'b1;
     end while ( dut_vif.pready === 0);
     req.data =  dut_vif.prdata;
  end  






  endtask 
  

endclass: apb_driver
