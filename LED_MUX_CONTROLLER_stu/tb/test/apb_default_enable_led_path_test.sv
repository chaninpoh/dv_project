// G01 — apb_default_enable_led_path_test (TESTPLAN §3 G01)
// Proves power-on LED_enable=1 without any APB write to 0x4000;
// drives error_q=7 and verifies seg_out via SCB-1, SCB-4..6, SCB-8.
class apb_default_enable_led_path_test extends base_test;
  `uvm_component_utils(apb_default_enable_led_path_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_default_enable_vseq vseq;
    phase.raise_objection(this);
    vseq = apb_default_enable_vseq::type_id::create("vseq");
    vseq.error_q = 20'd7;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 apb_default_enable_led_path_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
