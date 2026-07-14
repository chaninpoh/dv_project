// S07 — led_single_digit_one_test (TESTPLAN §1.3 S07)
// Drives error_q = 1 — display = 000001 (digit 1 at position 0, zeros elsewhere).
// Closes HVP item Single_digit_one_display and cg_digits cross (pos0, val=1) bin.
class led_single_digit_one_test extends base_test;
  `uvm_component_utils(led_single_digit_one_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd1;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_single_digit_one_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
