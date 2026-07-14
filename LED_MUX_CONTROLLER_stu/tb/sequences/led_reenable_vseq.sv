// G07 virtual sequence — disable LED, drive error_q (no effect), re-enable, drive new value
// Covers: SCB-7 (disable gates display), SCB-4..6, SCB-8 (re-enable display)
// Coverage: cg_enable.off_to_on transition
//
// Pre-loads error_q=42 while still disabled so the DUT sees 42 the moment
// LED_enable goes 1 (avoids stale error_q=55 being processed at re-enable).
// The fork then actively holds 42 for 1100 cycles while poll_seq runs concurrently,
// ensuring LED scanning and Done polling overlap so SCB-8 allows segment checks.
class led_reenable_vseq extends uvm_sequence;
  `uvm_object_utils(led_reenable_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q_disabled = 20'd55;  // driven while disabled — no display effect
  bit [19:0] error_q_enabled  = 20'd42;  // pre-loaded then actively held after re-enable

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq     reset_seq;
    apb_write_seq     enable_wr;
    led_error_seq     err_seq;
    apb_done_poll_seq poll_seq;

    // 1. Reset DUT
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // 2. Write LED_enable=1 (initial enable, updates SCB shadow)
    enable_wr = apb_write_seq::type_id::create("enable_on");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Disable LED (on_to_off transition)
    enable_wr = apb_write_seq::type_id::create("enable_off");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h0;
    enable_wr.start(p_sequencer.apb_seqr);

    // 4. Drive error_q=55 while disabled — SCB-7 gates LED transactions, no Done poll
    err_seq = led_error_seq::type_id::create("err_disabled");
    err_seq.error_q = error_q_disabled;
    err_seq.start(p_sequencer.led_seqr);

    // 5. Pre-load error_q=42 while STILL DISABLED so DUT sees 42 at moment of re-enable.
    //    Driver holds 42 on the interface after this call returns.
    err_seq = led_error_seq::type_id::create("err_preload");
    err_seq.error_q = error_q_enabled;
    err_seq.start(p_sequencer.led_seqr);

    // 6. Re-enable LED (off_to_on transition — closes cg_enable coverage gap)
    enable_wr = apb_write_seq::type_id::create("enable_reenable");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 7. Actively hold error_q=42 for 1100 cycles while concurrently polling Done.
    //    Fork ensures LED scanning and Done poll overlap so SCB-8 allows segment checks.
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_enabled");
        err_seq.error_q = error_q_enabled;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        poll_seq = apb_done_poll_seq::type_id::create("poll_seq");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

  endtask

endclass
