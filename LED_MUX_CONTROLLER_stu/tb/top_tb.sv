// ===============================================
// Project      : LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================
`include "uvm_macros.svh"


//`include "dp_if.sv"

module top_tb;
//__TB__ Import  UVM FILES//
import uvm_pkg::*;
// import my_testbench_pkg::*;

//__TB__// Import Agent Packages

//__TB__// include the env here: 
`include "my_env.sv"



//__TB__include test here
`include "test_lib.svh" //add +incdir+

// Signal declarations
logic dp_mux_clk;
logic rst_n;
logic [3:0] led;
logic [7:0] seg_out;
logic [5:0] sel_out;


initial begin
	//__TB__//Start the UVM phases
//	run_test();
end 

//set your reset
initial begin
	rst_n = 0;
	#1000ns;
	rst_n = 1;

end 


//create a clock
  initial begin
      dp_mux_clk = 0;
    forever begin
      #10ns;
      dp_mux_clk =~dp_mux_clk;
    end
  end





 wire CLK_OUT;
 wire RESET;

 assign RESET  = ~rst_n;


//__TB__//instantiate the interface:

initial begin
//__TB__//set the interface through uvm_config_db

//	uvm_config_db#(virtual dp_if)::set(null, "*agent1.monitor", "dut_vif", dp_if_inst);
//	uvm_config_db#(virtual dp_if)::set(null, "*agent1.driver", "dut_vif", dp_if_inst);              

end 


//INSTANTIATE THE DUT HERE
//__TB__//
/*
dut dut_inst(
	.clk(//CONNECT),
	.rst_n(//CONNECT),
        .i_paddr   (apb_if_inst.paddr),
        .i_pwrite  (//CONNECT),
        .i_psel    (//CONNECT),
        .i_penable (//CONNECT),
        .i_pwdata  (//CONNECT),
        .o_prdata  (//CONNECT),
        .o_pready  (ap//CONNECT),
        .o_pslverr (apb//CONNECT),
	.error_sig(//CONNECT),
	.seg_out(//CONNECT),
	.sel_out(//CONNECT)
);
*/

initial begin
   $fsdbDumpfile("waveform.fsdb");       // Set output file name
   $fsdbDumpvars(0, "top_tb");
   $fsdbDumpSVA;


end 

initial begin
//__TB__//remove when you have a uvm test	
 #1000ns;
$finish;
end 


//bind SVA
//bind dp_mux dp_sva dp_sva_inst(.clk(clk), .rst_n(rst_n), .error_q(error_q), .sel_out(sel_out), .seg_out(seg_out)); 
//SV Exercises
//`include "constraints.sv"


endmodule





