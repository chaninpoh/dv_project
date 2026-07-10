// Virtual sequence — reset then read all APB register reset defaults (E02)
class apb_reset_defaults_vseq extends uvm_sequence;
  `uvm_object_utils(apb_reset_defaults_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq reset_seq;
    apb_read_seq  rd;

    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);

    #100ns;

    // SCB-1: LED_enable default after reset
    rd = apb_read_seq::type_id::create("rd_led_enable");
    rd.addr = 32'h4000;
    rd.start(p_sequencer.apb_seqr);

    // SCB-2: Done default after reset
    rd = apb_read_seq::type_id::create("rd_done");
    rd.addr = 32'h4004;
    rd.start(p_sequencer.apb_seqr);

    // SCB-3: Scratchpad default after reset
    rd = apb_read_seq::type_id::create("rd_scratch");
    rd.addr = 32'h4008;
    rd.start(p_sequencer.apb_seqr);
  endtask

endclass
