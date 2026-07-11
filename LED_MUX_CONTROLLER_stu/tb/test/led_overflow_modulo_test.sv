// E09 — led_overflow_modulo_test (TESTPLAN §2.2)
// error_q=1_000_001 overflows 6-digit display; expected display = 000001 (SPEC §3.6)
// 1_000_001 fits in 20 bits (2^20 = 1_048_576 > 1_000_001)
class led_overflow_modulo_test extends base_test;
  `uvm_component_utils(led_overflow_modulo_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 1_000_001;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_overflow_modulo_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
