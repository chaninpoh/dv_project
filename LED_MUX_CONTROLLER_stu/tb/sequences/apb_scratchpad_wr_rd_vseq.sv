// Virtual sequence — write then read scratchpad 0x4008 = 32'hDEAD_BEEF (E04)
class apb_scratchpad_wr_rd_vseq extends uvm_sequence;
  `uvm_object_utils(apb_scratchpad_wr_rd_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  localparam bit [31:0] ADDR_SCRATCH = 32'h4008;
  localparam bit [31:0] WDATA        = 32'hDEAD_BEEF;

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

    wr = apb_write_seq::type_id::create("wr_scratch");
    wr.addr = ADDR_SCRATCH; wr.data = WDATA;
    wr.start(p_sequencer.apb_seqr);

    rd = apb_read_seq::type_id::create("rd_scratch");
    rd.addr = ADDR_SCRATCH;
    rd.start(p_sequencer.apb_seqr);
  endtask

endclass
