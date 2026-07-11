// E05 — APB invalid address → pslverr (TESTPLAN §2)
class apb_invalid_addr_test extends base_test;
  `uvm_component_utils(apb_invalid_addr_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_invalid_addr_vseq vseq;

    phase.raise_objection(this);

    vseq = apb_invalid_addr_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);

    `uvm_info("PHASE3_P0", "PHASE 3 : P0 apb_invalid_addr_test complete", UVM_LOW)

    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
