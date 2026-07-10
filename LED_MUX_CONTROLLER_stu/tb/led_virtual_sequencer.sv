class led_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(led_virtual_sequencer)

  uvm_sequencer #(apb_transaction) apb_seqr;
  uvm_sequencer #(led_transaction) led_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
