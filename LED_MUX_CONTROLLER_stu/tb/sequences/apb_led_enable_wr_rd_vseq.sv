// Virtual sequence — write/read LED_enable register 0x4000 (E03)
class apb_led_enable_wr_rd_vseq extends uvm_sequence;
  `uvm_object_utils(apb_led_enable_wr_rd_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq reset_seq;
    apb_write_seq wr;
    apb_read_seq  rd;

    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
    #100ns;

    // Write LED_enable = 1, verify readback
    wr = apb_write_seq::type_id::create("wr_en1");
    wr.addr = 32'h4000; wr.data = 32'h1;
    wr.start(p_sequencer.apb_seqr);

    rd = apb_read_seq::type_id::create("rd_en1");
    rd.addr = 32'h4000;
    rd.start(p_sequencer.apb_seqr);

    // Write LED_enable = 0, verify readback
    wr = apb_write_seq::type_id::create("wr_en0");
    wr.addr = 32'h4000; wr.data = 32'h0;
    wr.start(p_sequencer.apb_seqr);

    rd = apb_read_seq::type_id::create("rd_en0");
    rd.addr = 32'h4000;
    rd.start(p_sequencer.apb_seqr);
  endtask

endclass
