// P0 E07 — LED reset output values; checkers in led_mux_sva (TESTPLAN §2)
class led_reset_values_test extends base_test;
  `uvm_component_utils(led_reset_values_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_reset_vseq vseq;

    phase.raise_objection(this);

    vseq = led_reset_vseq::type_id::create("vseq");
    vseq.start(env.v_seqr);

    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_reset_values_test complete", UVM_LOW)

    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
