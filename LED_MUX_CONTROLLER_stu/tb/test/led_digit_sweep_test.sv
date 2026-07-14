// S18 — led_digit_sweep_test
// Drives 7 error_q values targeting all 25 uncovered cg_digits cross bins.
// Expect FAIL: values > 1023 expose BUG-006 (bin2bcd truncation).
// Coverage benefit: cg_digits cross bins are sampled from golden error_q value,
// not DUT output, so all target bins are captured regardless of BUG-006.
class led_digit_sweep_test extends base_test;
  `uvm_component_utils(led_digit_sweep_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_digit_sweep_vseq vseq;
    phase.raise_objection(this);
    vseq = led_digit_sweep_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);
    `uvm_info("TEST", "led_digit_sweep_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
