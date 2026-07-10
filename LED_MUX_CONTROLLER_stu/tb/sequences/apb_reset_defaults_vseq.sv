// Virtual sequence — runs all 3 APB register reset-default reads (E02)
class apb_reset_defaults_vseq extends uvm_sequence;
  `uvm_object_utils(apb_reset_defaults_vseq)

  uvm_sequencer #(apb_transaction) apb_seqr;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    apb_read_seq rd;

    // SCB-1: LED_enable default = 1 after reset
    rd = apb_read_seq::type_id::create("rd_led_enable");
    rd.addr = 32'h4000;
    rd.start(apb_seqr);

    // SCB-2: Done default = 0 after reset
    rd = apb_read_seq::type_id::create("rd_done");
    rd.addr = 32'h4004;
    rd.start(apb_seqr);

    // SCB-3: Scratchpad default = 0 after reset
    rd = apb_read_seq::type_id::create("rd_scratch");
    rd.addr = 32'h4008;
    rd.start(apb_seqr);
  endtask

endclass
