// G08 — full_display_flow_test (TESTPLAN §3 G08)
// Full path: LED_enable write, scratchpad write, LED display, scratchpad/Done readback.
// Exercises SCB-1..6, SCB-8 in a single end-to-end transaction sequence.
class full_display_flow_test extends base_test;
  `uvm_component_utils(full_display_flow_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    full_display_vseq vseq;
    phase.raise_objection(this);
    vseq = full_display_vseq::type_id::create("vseq");
    vseq.error_q = 20'd42;
    vseq.scratch  = 32'hCAFE_BABE;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 full_display_flow_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
