// G02 — apb_read_during_processing_test (TESTPLAN §3 G02)
// Reads Done register before assertion to confirm it is 0 (C-5 early-read check),
// then polls until Done=1; check_60_80_cycle SVA validates latency window.
class apb_read_during_processing_test extends base_test;
  `uvm_component_utils(apb_read_during_processing_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_read_during_processing_vseq vseq;
    phase.raise_objection(this);
    vseq = apb_read_during_processing_vseq::type_id::create("vseq");
    vseq.error_q = 20'd42;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 apb_read_during_processing_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
