// Virtual sequence for LED display tests (E08, E09, E10, E11)
// Drives error_q and polls Done concurrently (fork-join) so the scoreboard
// sees done=1 while the LED monitor is still scanning digit positions.
class led_mux_virtual_seq extends uvm_sequence;
  `uvm_object_utils(led_mux_virtual_seq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  bit [19:0] error_q   = 20'd42;  // override per test
  bit        led_enable = 1'b1;   // set to 0 for E10 (LED disable test)

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

    // 2. Write LED_enable (SPEC §3.4; explicit even when 1 to update SCB shadow)
    enable_wr = apb_write_seq::type_id::create("enable_wr");
    enable_wr.addr = 32'h4000;
    enable_wr.data = {31'h0, led_enable};
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Drive error_q and (if enabled) poll Done concurrently
    if (led_enable) begin
      // Fork: hold >= 1100 cycles AND poll Done so SCB sees done=1
      // while LED monitor is still scanning digit positions (SPEC C-4, C-5)
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
    end else begin
      // LED disabled: drive error_q (holds 1100 cycles); Done will not assert
      // SCB-7 in scoreboard gates out any LED monitor transactions
      err_seq = led_error_seq::type_id::create("err_seq");
      err_seq.error_q = error_q;
      err_seq.start(p_sequencer.led_seqr);
    end

  endtask

endclass
