// G05 — led_hold_time_min_test (TESTPLAN §3 G05)
// Drives error_q=1 with the standard 1100-cycle hold (>= 1002 required per SPEC C-4).
// check_hold_1002_cycle SVA validates the minimum hold; SCB-4 checks seg_out for digit 1.
class led_hold_time_min_test extends base_test;
  `uvm_component_utils(led_hold_time_min_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd1;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_hold_time_min_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
