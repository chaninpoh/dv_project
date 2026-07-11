// E11 — led_all_digits_0_to_9_test (TESTPLAN §2.2)
// Drives error_q=d for d in 0..9, verifies all 10 7-seg encodings (SCB-5, AC-C1)
class led_all_digits_0_to_9_test extends base_test;
  `uvm_component_utils(led_all_digits_0_to_9_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_all_digits_vseq vseq;
    phase.raise_objection(this);
    vseq = led_all_digits_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_all_digits_0_to_9_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
