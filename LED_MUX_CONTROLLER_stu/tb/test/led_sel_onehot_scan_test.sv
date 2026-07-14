// G04 — led_sel_onehot_scan_test (TESTPLAN §3 G04)
// Drives error_q=74565 and holds >= 1002 cycles; asserts sel_out one-hot per
// assert_sel_out_onehot_active_low SVA and samples cover_sel_out_digit_position.
class led_sel_onehot_scan_test extends base_test;
  `uvm_component_utils(led_sel_onehot_scan_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd74565;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_sel_onehot_scan_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
