// Virtual sequence for E11 — drives error_q=d for d in 0..9, polls Done each iteration
// Verifies all 10 decimal digit encodings per SPEC §4.4 (SCB-5)
class led_all_digits_vseq extends uvm_sequence;
  `uvm_object_utils(led_all_digits_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

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

    // 2. Enable LED (SPEC §3.4 default=1; explicit for SCB shadow)
    enable_wr = apb_write_seq::type_id::create("enable_wr");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Loop d=0..9: drive error_q=d (ones digit = d), poll Done, SCB-5 compares
    for (int d = 0; d <= 9; d++) begin
      fork
        begin
          err_seq = led_error_seq::type_id::create($sformatf("err_d%0d", d));
          err_seq.error_q = 20'(d);
          err_seq.start(p_sequencer.led_seqr);
        end
        begin
          poll_seq = apb_done_poll_seq::type_id::create($sformatf("poll_d%0d", d));
          poll_seq.start(p_sequencer.apb_seqr);
        end
      join
    end

  endtask

endclass
