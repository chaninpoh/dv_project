// E01 — smoke_test (TESTPLAN §2.2)
// Integration: reset → enable → error_q=42 → poll Done → all SCB + all §0.3 properties
class smoke_test extends base_test;
  `uvm_component_utils(smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.led_enable = 1'b1;
    vseq.error_q    = 20'd42;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 smoke_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
