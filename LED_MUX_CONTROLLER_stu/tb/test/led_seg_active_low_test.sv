// S08 — led_seg_active_low_test (TESTPLAN §1.3 S08)
// Drives error_q = 9 to exercise active-low segment encoding (SPEC §4.4).
// SCB-5 and SCB-6 verify correct active-low values and seg_out[7]==1.
// Closes HVP item seg_out_active_low_encoding.
class led_seg_active_low_test extends base_test;
  `uvm_component_utils(led_seg_active_low_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd9;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_seg_active_low_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
