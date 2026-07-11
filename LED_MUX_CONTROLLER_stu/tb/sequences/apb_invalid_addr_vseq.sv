// Virtual sequence — access unmapped address 0x400C, expect pslverr (E05)
class apb_invalid_addr_vseq extends uvm_sequence;
  `uvm_object_utils(apb_invalid_addr_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  localparam bit [31:0] INVALID_ADDR = 32'h400C;

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

    // Write to invalid address — SVA expects pslverr to assert
    wr = apb_write_seq::type_id::create("wr_invalid");
    wr.addr = INVALID_ADDR; wr.data = 32'hDEAD;
    wr.start(p_sequencer.apb_seqr);

    // Read from invalid address — SVA expects pslverr to assert
    rd = apb_read_seq::type_id::create("rd_invalid");
    rd.addr = INVALID_ADDR;
    rd.start(p_sequencer.apb_seqr);
  endtask

endclass
