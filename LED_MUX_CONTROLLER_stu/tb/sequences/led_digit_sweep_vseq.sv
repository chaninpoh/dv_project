// S18 — led_digit_sweep_vseq
// Sweeps 7 error_q values chosen to cover all 25 missing cg_digits cross bins:
//   pos_1: val_1,3,5   pos_2: val_2,3,4,6,8
//   pos_3: val_1,2,3,5,7   pos_4: val_1,2,3,6,8   pos_5: val_1,2,3,5,6,7,8
// Values > 1023 will trigger BUG-006 (wrong DUT display), so the test FAILs,
// but cg_digits samples the golden error_q value — coverage is captured regardless.
class led_digit_sweep_vseq extends uvm_sequence;
  `uvm_object_utils(led_digit_sweep_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  localparam int NUM_VALS = 7;
  // Each value's digits cover specific missing (pos, val) cross bins.
  // pos5  pos4  pos3  pos2  pos1  pos0
  //   1     3     5     2     1     3   → 135_213
  //   2     1     3     6     3     1   → 213_631
  //   3     2     7     4     8     5   → 327_485  (pos1=8: already covered, harmless)
  //   5     6     1     3     5     0   → 561_350
  //   6     8     2     8     0     0   → 682_800
  //   7     0     0     0     0     0   → 700_000
  //   8     0     0     0     0     0   → 800_000
  bit [19:0] sweep_vals[NUM_VALS] = '{
    20'd135_213,
    20'd213_631,
    20'd327_485,
    20'd561_350,
    20'd682_800,
    20'd700_000,
    20'd800_000
  };

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

    // 3. Sweep all 7 values — each fork drives error_q then waits for done
    for (int i = 0; i < NUM_VALS; i++) begin
      `uvm_info(get_type_name(),
        $sformatf("Sweep iter %0d: error_q=%0d", i, sweep_vals[i]), UVM_LOW)
      fork
        begin
          err_seq = led_error_seq::type_id::create($sformatf("err_%0d", i));
          err_seq.error_q = sweep_vals[i];
          err_seq.start(p_sequencer.led_seqr);
        end
        begin
          poll_seq = apb_done_poll_seq::type_id::create($sformatf("poll_%0d", i));
          poll_seq.start(p_sequencer.apb_seqr);
        end
      join
    end

  endtask

endclass
