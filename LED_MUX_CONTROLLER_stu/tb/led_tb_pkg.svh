// Scoreboard + coverage + sequences (must live in a package for VCS)
package led_tb_pkg;

  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import led_agent_pkg::*;

  `include "uvm_macros.svh"

  `include "led_scoreboard.sv"
  `include "led_coverage.sv"
  `include "led_virtual_sequencer.sv"

  // Sequences - include here, not in test_lib.svh
  `include "sequences/led_reset_seq.sv"
  `include "sequences/led_reset_vseq.sv"
  `include "sequences/apb_read_seq.sv"
  `include "sequences/apb_write_seq.sv"
  `include "sequences/apb_reset_defaults_vseq.sv"
  `include "sequences/apb_pready_no_wait_vseq.sv"
  `include "sequences/apb_led_enable_wr_rd_vseq.sv"
  `include "sequences/apb_scratchpad_wr_rd_vseq.sv"
  `include "sequences/apb_invalid_addr_vseq.sv"
  `include "sequences/led_error_seq.sv"
  `include "sequences/apb_done_poll_seq.sv"
  `include "sequences/led_mux_virtual_seq.sv"
  `include "sequences/led_all_digits_vseq.sv"

endpackage
