// S17 — enable_off_overflow_test (TESTPLAN §1.3 S17)
// Disables LED, drives overflow error_q (gated), re-enables with in-range value.
// Closes HVP item Disable_then_overflow_then_enable.
class enable_off_overflow_test extends base_test;
  `uvm_component_utils(enable_off_overflow_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    enable_off_overflow_vseq vseq;
    phase.raise_objection(this);
    vseq = enable_off_overflow_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 enable_off_overflow_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
