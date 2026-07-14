// G06 — led_latency_window_test (TESTPLAN §3 G06)
// Drives error_q=100; check_60_80_cycle SVA validates Done asserts within 60-80 cycle
// window; SCB-8 confirms seg_out only compared after Done=1.
class led_latency_window_test extends base_test;
  `uvm_component_utils(led_latency_window_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd100;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_latency_window_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
