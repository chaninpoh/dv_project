// S09 — led_overflow_max_test (TESTPLAN §1.3 S09)
// Drives error_q = 20'hFFFFF (1_048_575, absolute 20-bit max).
// Covers cg_error_q bin b1_048_575; golden = 1_048_575 % 1_000_000 = 48_575.
class led_overflow_max_test extends base_test;
  `uvm_component_utils(led_overflow_max_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'hFFFFF;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_overflow_max_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
