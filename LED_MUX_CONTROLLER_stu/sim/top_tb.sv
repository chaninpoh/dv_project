// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================
`include "uvm_macros.svh"


module top_tb;
 import uvm_pkg::*;
 import my_testbench_pkg::*;


//include test here
`include "test_lib.svh"




// Signal declarations
logic clk;
logic dp_mux_clk;
logic rst_n;
logic [3:0] led;
logic [7:0] seg_out;
logic [5:0] sel_out;


initial begin
	//Start the UVM phases
 	run_test();
end 

initial begin
	rst_n = 0;
	#1000ns;
	rst_n = 1;

end 


  initial begin
    clk = 0;
  //  #0.5ns;
    forever begin
      #1.5ns;
      clk =~clk;
    end
  end

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


//instantiate the interface:
dp_if dp_if_inst(dp_mux_clk, RESET);
dp_if dp_psv_if_inst(dp_mux_clk, RESET);
//assign f2s_s2f_if_inst.ready = 1;







initial begin
//INTEGRATING TB_001//	
uvm_config_db#(virtual dp_if)::set(null, "*agent1.*", "dut_vif", dp_if_inst);
uvm_config_db#(virtual dp_if)::set(null, "*psv_agent1.*", "dut_vif", dp_psv_if_inst);
end 


//INSTANTIATE THE DUT HERE
//INTEGRATING TB_001//
    dut dut_inst (
        .clk(dp_mux_clk),//connect to dp_if
        .rst_n(rst_n),
	.error_sig(dp_if_inst.error_sig), //connect to dp_if
        .seg_out(dp_psv_if_inst.seg_out),
        .sel_out(dp_psv_if_inst.sel_out)

    );




initial begin
   $fsdbDumpfile("waveform.fsdb");       // Set output file name
   $fsdbDumpvars(0, "top_tb");
   $fsdbDumpSVA; 

end 



//bind SVA
bind dp_mux dp_sva dp_sva_inst(.clk(clk), .rst_n(rst_n), .error_q(error_q), .sel_out(sel_out), .seg_out(seg_out)); 

//`include "err_inj.sv" //scb error


endmodule





