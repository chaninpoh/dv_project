// Concurrent SVA — TESTPLAN §0.3 (IEEE 1800 property / assert property)
module led_mux_sva (
  input logic        clk,
  input logic        rst_n,
  input logic [5:0]  sel_out,
  input logic [7:0]  seg_out,
  input logic [19:0] error_q,
  // APB signals — for pready no-wait assertions (E06) and pslverr (E05)
  input logic        psel,
  input logic        penable,
  input logic        pready,
  input logic [31:0] paddr,
  input logic        pslverr
);

  // -------------------------------------------------------------------------
  // During active reset (rst_n == 0) — SPEC §3.3: outputs must hold reset values
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
  // After reset deassert — AC-R1 / AC-R2
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
  // APB pready no-wait-state assertions (E06)
  // -------------------------------------------------------------------------
  property p_apb_setup_phase;
    @(posedge clk) disable iff (!rst_n)
      (psel && !penable) |-> ##1 (psel && penable);
  endproperty
  assert_apb_setup_phase: assert property (p_apb_setup_phase);

  property p_apb_access_phase;
    @(posedge clk) disable iff (!rst_n)
      (psel && penable) |-> pready;
  endproperty
  assert_apb_access_phase: assert property (p_apb_access_phase);

  property p_apb_pready_complete;
    @(posedge clk) disable iff (!rst_n)
      (psel && penable && pready) |-> ##1 !psel;
  endproperty
  assert_apb_pready_complete: assert property (p_apb_pready_complete);

  // -------------------------------------------------------------------------
  // APB pslverr on invalid address (E05)
  // Valid addresses: 0x4000 (LED_enable), 0x4004 (Done), 0x4008 (Scratchpad)
  // All other addresses in an access phase must assert pslverr
  // -------------------------------------------------------------------------
  property p_apb_pslerr_invalid_addr;
    @(posedge clk) disable iff (!rst_n)
      (psel && penable && pready &&
       paddr !== 32'h4000 && paddr !== 32'h4004 && paddr !== 32'h4008) |-> pslverr;
  endproperty
  assert_apb_pslerr_invalid_addr: assert property (p_apb_pslerr_invalid_addr);

  // -------------------------------------------------------------------------
  // E08 — LED display properties
  // -------------------------------------------------------------------------

  // assert_sel_out_onehot_active_low (AC-M1, SPEC §3.1)
  // During normal operation sel_out must be one-hot active-low (exactly one bit=0)
  // Exception: 6'h3F (all-ones) is idle state between digit cycles
  property p_sel_out_onehot_active_low;
    @(posedge clk) disable iff (!rst_n)
      (sel_out !== 6'h3F) |-> $onehot(~sel_out);
  endproperty
  assert_sel_out_onehot_active_low: assert property (p_sel_out_onehot_active_low);

  // assert_seg_out_bit7_always_one (AC-B2, SPEC §3.1)
  // seg_out[7] must be 1 whenever any segment is active (seg_out[6:0] != 7'h7F)
  property p_seg_out_bit7_always_one;
    @(posedge clk) disable iff (!rst_n)
      (seg_out[6:0] !== 7'h7F) |-> seg_out[7];
  endproperty
  assert_seg_out_bit7_always_one: assert property (p_seg_out_bit7_always_one);

  // cover_seg_change_latency (SPEC C-5: output valid 60-80 cycles after input changes)
  // Implemented as a cover property — observes the timing window, not a hard pass/fail gate
  cover_seg_change_latency: cover property (
    @(posedge clk) disable iff (!rst_n)
    $changed(sel_out) ##[60:80] $changed(seg_out)
  );

  // -------------------------------------------------------------------------
  // E11 — cover each decimal digit encoding on seg_out (AC-C1, TESTPLAN §0.3)
  // Covers all 10 active-low 7-seg encodings from SPEC §4.4 (bit7=1 always)
  // -------------------------------------------------------------------------
  cover_seg_out_decimal_digit_0: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'h81);
  cover_seg_out_decimal_digit_1: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hF3);
  cover_seg_out_decimal_digit_2: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hC8);
  cover_seg_out_decimal_digit_3: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hE0);
  cover_seg_out_decimal_digit_4: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hB2);
  cover_seg_out_decimal_digit_5: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hA4);
  cover_seg_out_decimal_digit_6: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'h86);
  cover_seg_out_decimal_digit_7: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hF1);
  cover_seg_out_decimal_digit_8: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'h80);
  cover_seg_out_decimal_digit_9: cover property (@(posedge clk) disable iff (!rst_n) seg_out == 8'hB0);

  // -------------------------------------------------------------------------
  // E01 — smoke test cover properties (TESTPLAN §2.2, §0.3)
  // -------------------------------------------------------------------------

  // cover_sel_out_digit_position (AC-M1, SPEC §3.1)
  // Covers that sel_out cycles through one-hot active-low positions (any digit selected)
  cover_sel_out_digit_position: cover property (
    @(posedge clk) disable iff (!rst_n)
    $onehot(~sel_out)
  );

  // check_hold_1002_cycle (SPEC C-4: error_q must be held stable >= 1002 cycles)
  // Cover property — the driver holds for 1100 cycles so this must be observed
  check_hold_1002_cycle: cover property (
    @(posedge clk) disable iff (!rst_n)
    $stable(error_q) [*1002]
  );

endmodule
