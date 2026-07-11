// E10 — led_disable_blocks_update_test (TESTPLAN §2.2)
// Writes LED_enable=0 then drives error_q=55; confirms seg_out does not update (SCB-7)
class led_disable_blocks_update_test extends base_test;
  `uvm_component_utils(led_disable_blocks_update_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.led_enable = 1'b0;
    vseq.error_q    = 20'd55;
    vseq.start(env.v_seqr);
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_disable_blocks_update_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
