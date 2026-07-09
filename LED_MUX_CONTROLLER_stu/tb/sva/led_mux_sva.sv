// Concurrent SVA — TESTPLAN §0.3 (IEEE 1800 property / assert property)
module led_mux_sva (
  input logic       clk,
  input logic       rst_n,
  input logic [5:0] sel_out,
  input logic [7:0] seg_out
);

  // E07 / E02 — AC-R1: sel_out after reset deassert (SPEC §3.3)
  property p_sel_out_reset_value;
    @(posedge clk) disable iff (!rst_n)
      $rose(rst_n) |-> ##1 (sel_out == 6'h3E);
  endproperty
  assert_sel_out_reset_value: assert property (p_sel_out_reset_value);

  // E07 / E02 — AC-R2: seg_out after reset deassert (SPEC §3.3)
  property p_seg_out_reset_value;
    @(posedge clk) disable iff (!rst_n)
      $rose(rst_n) |-> ##1 (seg_out == 8'h80);
  endproperty
  assert_seg_out_reset_value: assert property (p_seg_out_reset_value);

endmodule
