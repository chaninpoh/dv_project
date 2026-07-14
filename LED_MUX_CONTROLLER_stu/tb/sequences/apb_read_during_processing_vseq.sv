// G02 virtual sequence — reads Done early (before assertion) then polls to completion
// Verifies Done is 0 initially (SCB-2 monotonic), then 1 after 60-80 cycle window (check_60_80_cycle)
class apb_read_during_processing_vseq extends uvm_sequence;
  `uvm_object_utils(apb_read_during_processing_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q = 20'd42;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq     reset_seq;
    apb_write_seq     enable_wr;
    apb_read_seq      rd_done;
    led_error_seq     err_seq;
    apb_done_poll_seq poll_seq;

    // 1. Reset DUT
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // 2. Write LED_enable=1
    enable_wr = apb_write_seq::type_id::create("enable_wr");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Fork: drive error_q concurrently with early Done read + final poll
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_seq");
        err_seq.error_q = error_q;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        // Early read at ~10 cycles into processing (well before 60-80 cycle Done window)
        #200ns;
        rd_done = apb_read_seq::type_id::create("done_early");
        rd_done.addr = 32'h4004;
        rd_done.start(p_sequencer.apb_seqr);

        // Poll until Done=1 — check_60_80_cycle SVA validates the assertion window
        poll_seq = apb_done_poll_seq::type_id::create("poll_seq");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

  endtask

endclass
