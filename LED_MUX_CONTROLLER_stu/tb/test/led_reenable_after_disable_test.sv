// G07 — led_reenable_after_disable_test (TESTPLAN §3 G07)
// Disables LED, drives error_q=55 (no effect), re-enables, drives error_q=42,
// confirms display resumes correctly via SCB-7 then SCB-4..6, SCB-8.
class led_reenable_after_disable_test extends base_test;
  `uvm_component_utils(led_reenable_after_disable_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_reenable_vseq vseq;
    phase.raise_objection(this);
    vseq = led_reenable_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_reenable_after_disable_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
