// G03 — led_max_displayable_test (TESTPLAN §3 G03)
// Drives error_q=999_999 (maximum in-range value); all 6 digit positions display 9.
// Verifies SCB-4..6 for all-nines and closes cg_error_q.b999_999 boundary bin.
class led_max_displayable_test extends base_test;
  `uvm_component_utils(led_max_displayable_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd999_999;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_max_displayable_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
