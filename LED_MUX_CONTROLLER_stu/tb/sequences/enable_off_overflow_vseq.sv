// S17 virtual sequence — disable + overflow + re-enable
// 1. Reset, 2. Enable, 3. Disable, 4. Drive overflow error_q (gated by SCB-7),
// 5. Re-enable, 6. Drive in-range error_q + poll Done.
// Closes HVP item Disable_then_overflow_then_enable.
class enable_off_overflow_vseq extends uvm_sequence;
  `uvm_object_utils(enable_off_overflow_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq     reset_seq;
    apb_write_seq     enable_wr;
    led_error_seq     err_seq;
    apb_done_poll_seq poll_seq;

    // 1. Reset
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // 2. Write LED_enable=1
    enable_wr = apb_write_seq::type_id::create("en1");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Disable LED (SCB-7 should gate any updates)
    enable_wr = apb_write_seq::type_id::create("dis");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h0;
    enable_wr.start(p_sequencer.apb_seqr);

    // 4. Drive overflow value while disabled (SCB-7 gates display update)
    err_seq = led_error_seq::type_id::create("err_overflow");
    err_seq.error_q = 20'd1_000_001;
    err_seq.start(p_sequencer.led_seqr);

    // 5. Pre-load in-range value while still disabled, then re-enable
    err_seq = led_error_seq::type_id::create("err_preload");
    err_seq.error_q = 20'd42;
    err_seq.start(p_sequencer.led_seqr);

    enable_wr = apb_write_seq::type_id::create("en2");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 6. Drive in-range value + poll Done after re-enable
    `uvm_info(get_type_name(), "Re-enabled: driving error_q=42 and polling Done", UVM_LOW)
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_final");
        err_seq.error_q = 20'd42;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        poll_seq = apb_done_poll_seq::type_id::create("poll_final");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

  endtask

endclass
