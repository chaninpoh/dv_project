// S10 — led_overflow_boundary_vseq (TESTPLAN §1.3 S10)
// Sweeps four boundary values: 99 (b99 bin), 999_999 (in-range max),
// 1_000_000 (exact overflow boundary, b1_000_000 bin), 1_000_001 (overflow+1).
// Covers cg_error_q bins b99 and b1_000_000; exercises overflow modulo path.
class led_overflow_boundary_vseq extends uvm_sequence;
  `uvm_object_utils(led_overflow_boundary_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  localparam int NUM_VALS = 4;
  bit [19:0] boundary_vals[NUM_VALS] = '{
    20'd99,         // in-range: cg_error_q b99
    20'd999_999,    // in-range max: cg_error_q (golden = 999999)
    20'd1_000_000,  // exact boundary: cg_error_q b1_000_000 (golden = 000000)
    20'd1_000_001   // overflow+1: golden = 000001
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

    // 3. Sweep boundary values
    for (int i = 0; i < NUM_VALS; i++) begin
      `uvm_info(get_type_name(),
        $sformatf("Boundary iter %0d: error_q=%0d", i, boundary_vals[i]), UVM_LOW)
      fork
        begin
          err_seq = led_error_seq::type_id::create($sformatf("err_%0d", i));
          err_seq.error_q = boundary_vals[i];
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
