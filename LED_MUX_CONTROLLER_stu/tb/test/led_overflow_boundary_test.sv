// S10 — led_overflow_boundary_test (TESTPLAN §1.3 S10)
// Sweeps error_q = 99, 999_999, 1_000_000, 1_000_001 to cover
// cg_error_q bins b99 and b1_000_000 and exercise the overflow modulo boundary.
class led_overflow_boundary_test extends base_test;
  `uvm_component_utils(led_overflow_boundary_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_overflow_boundary_vseq vseq;
    phase.raise_objection(this);
    vseq = led_overflow_boundary_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_overflow_boundary_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
