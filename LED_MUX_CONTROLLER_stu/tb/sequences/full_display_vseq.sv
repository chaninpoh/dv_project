// G08 virtual sequence — full display flow with scratchpad
// Flow: reset → LED_enable=1 → scratchpad write → error_q drive + Done poll → read scratch → read Done
// SCB-1 (LED_enable), SCB-3 (scratchpad), SCB-4..6 (seg_out), SCB-8 (Done gate)
class full_display_vseq extends uvm_sequence;
  `uvm_object_utils(full_display_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q   = 20'd42;
  bit [31:0] scratch   = 32'hCAFE_BABE;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq     reset_seq;
    apb_write_seq     wr_seq;
    apb_read_seq      rd_seq;
    led_error_seq     err_seq;
    apb_done_poll_seq poll_seq;

    // 1. Reset DUT
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // 2. Write LED_enable=1
    wr_seq = apb_write_seq::type_id::create("enable_wr");
    wr_seq.addr = 32'h4000;
    wr_seq.data = 32'h1;
    wr_seq.start(p_sequencer.apb_seqr);

    // 3. Write scratchpad
    wr_seq = apb_write_seq::type_id::create("scratch_wr");
    wr_seq.addr = 32'h4008;
    wr_seq.data = scratch;
    wr_seq.start(p_sequencer.apb_seqr);

    // 4. Drive error_q and poll Done concurrently
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_seq");
        err_seq.error_q = error_q;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        poll_seq = apb_done_poll_seq::type_id::create("poll_seq");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

    // 5. Read scratchpad — SCB-3 verifies retained value
    rd_seq = apb_read_seq::type_id::create("scratch_rd");
    rd_seq.addr = 32'h4008;
    rd_seq.start(p_sequencer.apb_seqr);

    // 6. Read Done — SCB-2 confirms sticky latch (should still be 1)
    rd_seq = apb_read_seq::type_id::create("done_rd");
    rd_seq.addr = 32'h4004;
    rd_seq.start(p_sequencer.apb_seqr);

  endtask

endclass
