// Concurrent SVA — TESTPLAN §0.3 (IEEE 1800 property / assert property)
module led_mux_sva (
  input logic       clk,
  input logic       rst_n,
  input logic [5:0] sel_out,
  input logic [7:0] seg_out
);

  // -------------------------------------------------------------------------
  // During active reset (rst_n == 0) — SPEC §3.3: outputs must hold reset values
  // disable iff (rst_n) => property runs only while reset is asserted
  // Catches sel_out toggling (e.g. 3E -> 3D -> 3B ...) during reset
  // -------------------------------------------------------------------------
  property p_sel_out_during_reset;
    @(posedge clk) disable iff (rst_n)
      (sel_out == 6'h3E);
  endproperty
  assert_sel_out_stable_during_reset: assert property (p_sel_out_during_reset);

  property p_seg_out_during_reset;
    @(posedge clk) disable iff (rst_n)
      (seg_out == 8'h80);
  endproperty
  assert_seg_out_stable_during_reset: assert property (p_seg_out_during_reset);

  // -------------------------------------------------------------------------
  // After reset deassert — AC-R1 / AC-R2 (TESTPLAN assert_sel_out_reset_value)
  // disable iff (!rst_n) => property runs only when out of reset
  // -------------------------------------------------------------------------
  property p_sel_out_after_reset;
    @(posedge clk) disable iff (!rst_n)
      $rose(rst_n) |-> ##1 (sel_out == 6'h3E);
  endproperty
  assert_sel_out_reset_value: assert property (p_sel_out_after_reset);

  property p_seg_out_after_reset;
    @(posedge clk) disable iff (!rst_n)
      $rose(rst_n) |-> ##1 (seg_out == 8'h80);
  endproperty
  assert_seg_out_reset_value: assert property (p_seg_out_after_reset);

endmodule
