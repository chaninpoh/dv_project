// Virtual sequence — drives reset via led agent sequencer (E07, E02, E06)
class led_reset_vseq extends uvm_sequence;
  `uvm_object_utils(led_reset_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_reset_seq reset_seq;
    reset_seq = led_reset_seq::type_id::create("reset_seq");
    reset_seq.start(p_sequencer.led_seqr);
  endtask

endclass
