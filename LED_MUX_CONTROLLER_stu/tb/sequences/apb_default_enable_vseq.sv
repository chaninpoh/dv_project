// G01 virtual sequence — proves LED_enable=1 by default (no write to 0x4000)
// SCB-1 fires on the read to confirm default; SCB-4..6, SCB-8 check display for error_q=7
class apb_default_enable_vseq extends uvm_sequence;
  `uvm_object_utils(apb_default_enable_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q = 20'd7;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq     reset_seq;
    apb_read_seq      enable_rd;
    led_error_seq     err_seq;
    apb_done_poll_seq poll_seq;

    // 1. Reset DUT
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // 2. Read LED_enable — no prior write; SCB-1 confirms default=1
    enable_rd = apb_read_seq::type_id::create("enable_rd");
    enable_rd.addr = 32'h4000;
    enable_rd.start(p_sequencer.apb_seqr);

    // 3. Drive error_q and poll Done concurrently (default LED_enable assumed active)
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

  endtask

endclass
