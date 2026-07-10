// Virtual sequence — reset, then write+read scratchpad 0x4008 (E06)
class apb_pready_no_wait_vseq extends uvm_sequence;
  `uvm_object_utils(apb_pready_no_wait_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)

  localparam bit [31:0] ADDR_SCRATCH = 32'h4008;
  localparam bit [31:0] WDATA        = 32'hABCD_1234;

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

    // Write scratchpad — exercises setup + access phase for write
    wr = apb_write_seq::type_id::create("wr_scratch");
    wr.addr = ADDR_SCRATCH;
    wr.data = WDATA;
    wr.start(p_sequencer.apb_seqr);

    // Read same register — exercises setup + access phase for read; SCB-3 verifies value
    rd = apb_read_seq::type_id::create("rd_scratch");
    rd.addr = ADDR_SCRATCH;
    rd.start(p_sequencer.apb_seqr);
  endtask

endclass
