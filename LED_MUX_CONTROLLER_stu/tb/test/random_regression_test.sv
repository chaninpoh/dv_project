// G09 — random_regression_test (TESTPLAN §3 G09)
// Runs 5 iterations with mixed in-range and overflow error_q values.
// Exercises all SCB paths, all §0.3 SVA properties, and COV covergroups.
class random_regression_test extends base_test;
  `uvm_component_utils(random_regression_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    random_regression_vseq vseq;
    phase.raise_objection(this);
    vseq = random_regression_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 random_regression_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
