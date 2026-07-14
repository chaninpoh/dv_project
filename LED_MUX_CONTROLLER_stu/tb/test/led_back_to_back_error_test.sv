// S11 — led_back_to_back_error_test (TESTPLAN §1.3 S11)
// Drives error_q=7 then error_q=123 back-to-back without reset.
// Closes HVP item Back_to_back_error_q_changes; stresses BCD pipeline.
class led_back_to_back_error_test extends base_test;
  `uvm_component_utils(led_back_to_back_error_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_back_to_back_vseq vseq;
    phase.raise_objection(this);
    vseq = led_back_to_back_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_back_to_back_error_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
