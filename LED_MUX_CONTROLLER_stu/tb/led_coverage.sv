// Functional coverage - TESTPLAN 0.4 (one component; sample from APB/LED analysis)
// Included from led_tb_pkg.svh - analysis-imp macros must precede the class
`uvm_analysis_imp_decl(_cov_apb)
`uvm_analysis_imp_decl(_cov_led)

class led_coverage extends uvm_component;
  `uvm_component_utils(led_coverage)

  uvm_analysis_imp_cov_apb #(apb_transaction, led_coverage) apb_imp;
  uvm_analysis_imp_cov_led #(led_transaction, led_coverage) led_imp;

  localparam bit [31:0] ADDR_LED_ENABLE = 32'h4000;
  localparam bit [31:0] ADDR_DONE       = 32'h4004;

  typedef enum int {
    EN_OFF_TO_ON        = 0,
    EN_ON_TO_OFF        = 1,
    EN_DEFAULT_AT_RESET = 2
  } enable_trans_e;

  // Mirror / sample vars (SPEC 3.2-3.6)
  bit             led_enable;
  bit             done;
  bit             saw_enable_write;
  bit             prev_enable;
  bit             sample_enable_trans;
  enable_trans_e  enable_trans;
  bit             poll_while_0;
  bit [19:0]      error_q_cp;
  int             digit_pos;
  int             digit_val;

  covergroup cg_enable;
    option.per_instance = 1;
    cp_led_enable: coverpoint led_enable {
      bins bin_off = {0};
      bins bin_on  = {1};
    }
    cp_enable_trans: coverpoint enable_trans iff (sample_enable_trans) {
      bins off_to_on        = {EN_OFF_TO_ON};
      bins on_to_off        = {EN_ON_TO_OFF};
      bins default_at_reset = {EN_DEFAULT_AT_RESET};
    }
  endgroup

  covergroup cg_done;
    option.per_instance = 1;
    cp_done: coverpoint done {
      bins bin_0 = {0};
      bins bin_1 = {1};
    }
    cp_poll_before_done: coverpoint poll_while_0 {
      bins polled_while_0 = {1};
    }
  endgroup

  covergroup cg_error_q;
    option.per_instance = 1;
    cp_error_q: coverpoint error_q_cp {
      bins b0         = {0};
      bins b1         = {1};
      bins b9         = {9};
      bins b99        = {99};
      bins b999_999   = {999_999};
      bins b1_000_000 = {1_000_000};
      bins b1_048_575 = {1_048_575};
      bins mid_range  = {[2:8], [10:98], [100:999_998], [1_000_001:1_048_574]};
    }
  endgroup

  covergroup cg_overflow;
    option.per_instance = 1;
    cp_range: coverpoint error_q_cp {
      bins in_range = {[0:999_999]};
      bins overflow = {[1_000_000:1_048_575]};
    }
  endgroup

  covergroup cg_digits;
    option.per_instance = 1;
    cp_digit_pos: coverpoint digit_pos {
      bins pos[] = {[0:5]};
    }
    cp_digit_val: coverpoint digit_val {
      bins val[] = {[0:9]};
    }
    cx_digit_pos_x_digit_val: cross cp_digit_pos, cp_digit_val;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_enable   = new();
    cg_done     = new();
    cg_error_q  = new();
    cg_overflow = new();
    cg_digits   = new();
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for led_coverage", UVM_LOW)
    led_enable          = 1'b1;  // SPEC default after reset
    done                = 1'b0;
    saw_enable_write    = 1'b0;
    prev_enable         = 1'b1;
    sample_enable_trans = 1'b0;
    poll_while_0        = 1'b0;
    digit_pos           = 0;
    digit_val           = 0;
    apb_imp = new("apb_imp", this);
    led_imp = new("led_imp", this);
  endfunction

  function void write_cov_apb(apb_transaction tr);
    sample_enable_trans = 1'b0;
    poll_while_0        = 1'b0;

    if (tr.addr == ADDR_LED_ENABLE) begin
      if (tr.op == apb_transaction::WRITE) begin
        if (prev_enable == 1'b0 && tr.data[0] == 1'b1) begin
          enable_trans        = EN_OFF_TO_ON;
          sample_enable_trans = 1'b1;
        end else if (prev_enable == 1'b1 && tr.data[0] == 1'b0) begin
          enable_trans        = EN_ON_TO_OFF;
          sample_enable_trans = 1'b1;
        end
        led_enable       = tr.data[0];
        prev_enable      = tr.data[0];
        saw_enable_write = 1'b1;
        cg_enable.sample();
      end else if (tr.op == apb_transaction::READ) begin
        led_enable = tr.data[0];
        // E02: first enable read after reset with default 1 -> default_at_reset
        if (!saw_enable_write && tr.data[0] == 1'b1) begin
          enable_trans        = EN_DEFAULT_AT_RESET;
          sample_enable_trans = 1'b1;
        end
        cg_enable.sample();
      end
    end

    if (tr.addr == ADDR_DONE && tr.op == apb_transaction::READ) begin
      done = tr.data[0];
      if (!tr.data[0])
        poll_while_0 = 1'b1;
      cg_done.sample();
    end
  endfunction

  function void write_cov_led(led_transaction tr);
    automatic int pos;
    automatic bit [19:0] display_val;

    error_q_cp = tr.error_q;
    cg_error_q.sample();
    cg_overflow.sample();

    // Digits: after Done==1, per active digit (TESTPLAN 0.4)
    if (!done)
      return;
    if (tr.sel_out === 6'h3F)
      return;

    pos = -1;
    for (int i = 0; i < 6; i++) begin
      if (!tr.sel_out[i]) begin
        pos = i;
        break;
      end
    end
    if (pos < 0)
      return;

    digit_pos   = pos;
    display_val = tr.error_q % 1_000_000;
    begin
      automatic int divisor = 1;
      for (int k = 0; k < digit_pos; k++)
        divisor *= 10;
      digit_val = int'(display_val / divisor) % 10;
    end
    cg_digits.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf(
      "COV: cg_enable=%.1f%% cg_done=%.1f%% cg_error_q=%.1f%% cg_overflow=%.1f%% cg_digits=%.1f%%",
      cg_enable.get_inst_coverage(),
      cg_done.get_inst_coverage(),
      cg_error_q.get_inst_coverage(),
      cg_overflow.get_inst_coverage(),
      cg_digits.get_inst_coverage()), UVM_LOW)
  endfunction

endclass
