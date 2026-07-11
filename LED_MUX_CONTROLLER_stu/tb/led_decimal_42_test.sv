// E08 — led_decimal_42_test (TESTPLAN §2.2)
// Drives error_q=42, polls Done, verifies 6-digit display: 0,0,0,0,4,2
class led_decimal_42_test extends base_test;
  `uvm_component_utils(led_decimal_42_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd42;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_decimal_42_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
