// S06 — led_single_digit_zero_test (TESTPLAN §1.3 S06)
// Drives error_q = 0 — all six display positions must show digit 0.
// Closes HVP item Single_digit_zero_display and cg_digits cross (pos, val=0) bins.
class led_single_digit_zero_test extends base_test;
  `uvm_component_utils(led_single_digit_zero_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd0;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_single_digit_zero_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
