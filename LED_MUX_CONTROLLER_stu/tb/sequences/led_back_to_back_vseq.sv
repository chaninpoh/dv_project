// S11 virtual sequence — back-to-back error_q changes
// Drives two consecutive error_q values without reset between them.
// Stresses BCD pipeline update path; exercises Back_to_back_error_q_changes HVP item.
class led_back_to_back_vseq extends uvm_sequence;
  `uvm_object_utils(led_back_to_back_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q_a = 20'd7;
  bit [19:0] error_q_b = 20'd123;

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

    // 2. Write LED_enable=1
    enable_wr = apb_write_seq::type_id::create("enable_wr");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. First error_q: drive + poll Done
    `uvm_info(get_type_name(),
      $sformatf("B2B pass 1: error_q=%0d", error_q_a), UVM_LOW)
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_a");
        err_seq.error_q = error_q_a;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        poll_seq = apb_done_poll_seq::type_id::create("poll_a");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

    // 4. Immediately drive second error_q without reset (back-to-back)
    `uvm_info(get_type_name(),
      $sformatf("B2B pass 2: error_q=%0d", error_q_b), UVM_LOW)
    fork
      begin
        err_seq = led_error_seq::type_id::create("err_b");
        err_seq.error_q = error_q_b;
        err_seq.start(p_sequencer.led_seqr);
      end
      begin
        poll_seq = apb_done_poll_seq::type_id::create("poll_b");
        poll_seq.start(p_sequencer.apb_seqr);
      end
    join

  endtask

endclass
