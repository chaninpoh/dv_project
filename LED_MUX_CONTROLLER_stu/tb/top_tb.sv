// Phase 1 — static testbench top
`include "uvm_macros.svh"

module top_tb;

  import uvm_pkg::*;

  `include "test_lib.svh"

  logic clk;
  logic rst_n;

  apb_if apb_vif (.clk(clk), .rst_n(rst_n));
  led_if led_vif (.clk(clk), .rst_n(rst_n));

  dut dut_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_paddr    (apb_vif.paddr),
    .i_pwrite   (apb_vif.pwrite),
    .i_psel     (apb_vif.psel),
    .i_penable  (apb_vif.penable),
    .i_pwdata   (apb_vif.pwdata),
    .o_prdata   (apb_vif.prdata),
    .o_pready   (apb_vif.pready),
    .o_pslverr  (apb_vif.pslverr),
    .seg_out    (led_vif.seg_out),
    .sel_out    (led_vif.sel_out),
    .error_sig  (led_vif.error_q)
  );

  // 10 ns period clock (50 MHz simulation equivalent)
  initial begin
    clk = 0;
    forever #10ns clk = ~clk;
  end

  // Active-low reset — hold >= 100 ns
  initial begin
    rst_n = 0;
    #1000ns;
    rst_n = 1;
  end

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt*", "dut_vif", apb_vif);
    uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt*", "vif", apb_vif);
    uvm_config_db#(virtual led_if)::set(null, "uvm_test_top.env.led_agt*", "dut_vif", led_vif);
    uvm_config_db#(virtual led_if)::set(null, "uvm_test_top.env.led_agt*", "vif", led_vif);
    run_test();
  end

  initial begin
    $fsdbDumpfile("waveform.fsdb");
    $fsdbDumpvars(0, top_tb);
  end

endmodule
