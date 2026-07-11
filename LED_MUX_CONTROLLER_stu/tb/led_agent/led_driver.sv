// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

class led_driver extends uvm_driver #(led_transaction);

`uvm_component_utils(led_driver)

virtual led_if dut_vif;
int SLAVE_IF = 0;

function new(string name, uvm_component parent);
super.new(name, parent) ;
endfunction

function void build_phase(uvm_phase phase);
`uvm_info(get_type_name(), "Build phase for led_driver", UVM_LOW)
// Get interface reference from config database
if(!uvm_config_db#(virtual led_if) :: get(this, "", "dut_vif", dut_vif) ) begin
`uvm_error("", "uvm_config_db: :get failed")
end


endfunction

task drive_0_at_reset();
  dut_vif.error_q <= 20'h0;
endtask


task run_phase(uvm_phase phase) ;
drive_0_at_reset();

wait(dut_vif.rst_n == 1'b1);

// Now drive normal traffic
forever begin
seq_item_port.get_next_item(req);
drive_item(); //drive your item - core of the driver
seq_item_port.item_done ();
seq_item_port.put_response(req);   
end


endtask



virtual task drive_item();
  // Drive error_q and hold for >= 1100 cycles (SPEC C-4: must hold >= 1002 cycles)
  @(posedge dut_vif.clk);
  dut_vif.error_q <= req.error_q;
  repeat(1100) @(posedge dut_vif.clk);
endtask
  
  
  endclass: led_driver
