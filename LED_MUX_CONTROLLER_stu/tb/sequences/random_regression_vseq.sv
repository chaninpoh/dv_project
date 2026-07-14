// G09 virtual sequence — simplified random regression: 5 iterations mixing in-range and overflow
// 80% in-range (< 1_000_000), 20% overflow (>= 1_000_000); exercises all SCB paths and COV
class random_regression_vseq extends uvm_sequence;
  `uvm_object_utils(random_regression_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  // Fixed seed-independent values covering in-range and overflow cases
  localparam int NUM_ITER = 5;
  bit [19:0] test_values[NUM_ITER] = '{
    20'd7,          // in-range: single digit
    20'd123,        // in-range: three digits
    20'd456789,     // in-range: six digits
    20'd1_000_001,  // overflow: modulo = 1
    20'd42          // in-range: E08 reference value
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

    // 2. Write LED_enable=1 once
    enable_wr = apb_write_seq::type_id::create("enable_wr");
    enable_wr.addr = 32'h4000;
    enable_wr.data = 32'h1;
    enable_wr.start(p_sequencer.apb_seqr);

    // 3. Iterate over test values
    for (int i = 0; i < NUM_ITER; i++) begin
      `uvm_info(get_type_name(),
        $sformatf("RR iter %0d: error_q=%0d", i, test_values[i]), UVM_LOW)
      fork
        begin
          err_seq = led_error_seq::type_id::create($sformatf("err_%0d", i));
          err_seq.error_q = test_values[i];
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
