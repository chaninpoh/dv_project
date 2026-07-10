// Concurrent SVA — TESTPLAN §0.3 (IEEE 1800 property / assert property)
module led_mux_sva (
  input logic       clk,
  input logic       rst_n,
  input logic [5:0] sel_out,
  input logic [7:0] seg_out,
  // APB signals — for pready no-wait assertions (E06)
  input logic       psel,
  input logic       penable,
  input logic       pready
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

  // -------------------------------------------------------------------------
  // APB pready no-wait-state assertions (E06 / TESTPLAN §0.3)
  // WAIT_WRITE=0, WAIT_READ=0 — slave must assert pready within same access phase
  // -------------------------------------------------------------------------

  // Setup phase (psel=1, penable=0) must be followed immediately by access phase
  property p_apb_setup_phase;
    @(posedge clk) disable iff (!rst_n)
      (psel && !penable) |-> ##1 (psel && penable);
  endproperty
  assert_apb_setup_phase: assert property (p_apb_setup_phase);

  // In the access phase pready must already be asserted (no wait states)
  property p_apb_access_phase;
    @(posedge clk) disable iff (!rst_n)
      (psel && penable) |-> pready;
  endproperty
  assert_apb_access_phase: assert property (p_apb_access_phase);

  // Once pready is seen in the access phase, psel deasserts next cycle
  property p_apb_pready_complete;
    @(posedge clk) disable iff (!rst_n)
      (psel && penable && pready) |-> ##1 !psel;
  endproperty
  assert_apb_pready_complete: assert property (p_apb_pready_complete);

endmodule
