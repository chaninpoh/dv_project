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
  `include "sequences/apb_default_enable_vseq.sv"
  `include "sequences/led_reenable_vseq.sv"
  `include "sequences/full_display_vseq.sv"
  `include "sequences/apb_read_during_processing_vseq.sv"
  `include "sequences/random_regression_vseq.sv"
  `include "sequences/led_overflow_boundary_vseq.sv"
  `include "sequences/led_back_to_back_vseq.sv"
  `include "sequences/enable_off_overflow_vseq.sv"
  `include "sequences/led_digit_sweep_vseq.sv"

endpackage
