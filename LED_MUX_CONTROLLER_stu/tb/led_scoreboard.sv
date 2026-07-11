// Phase 3 — single scoreboard for all P0 tests (extend SCB logic per test)
// Included from led_tb_pkg.svh — macros must be before class declaration
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_led)

class led_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(led_scoreboard)

  uvm_analysis_imp_apb #(apb_transaction, led_scoreboard) apb_imp;
  uvm_analysis_imp_led #(led_transaction, led_scoreboard) led_imp;

  // Register mirror (SPEC §3.2)
  localparam bit [31:0] ADDR_LED_ENABLE = 32'h4000;
  localparam bit [31:0] ADDR_DONE       = 32'h4004;
  localparam bit [31:0] ADDR_SCRATCH    = 32'h4008;

  bit        led_enable;
  bit        done;
  bit [31:0] scratchpad;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for led_scoreboard", UVM_LOW)
    led_enable = 1'b1;  // SPEC default after reset
    done       = 1'b0;
    scratchpad = 32'h0;
    apb_imp = new("apb_imp", this);
    led_imp = new("led_imp", this);
  endfunction

  function void write_apb(apb_transaction tr);
    // SCB-1: mirror LED_enable on writes; check on reads
    // SCB-2: check Done default = 0 on reads from 0x4004
    // SCB-3: mirror scratchpad on writes; check on reads from 0x4008
    if (tr.op == apb_transaction::WRITE) begin
      case (tr.addr)
        ADDR_LED_ENABLE: led_enable = tr.data[0];
        ADDR_SCRATCH:    scratchpad = tr.data;
      endcase
    end else if (tr.op == apb_transaction::READ) begin
      case (tr.addr)
        ADDR_LED_ENABLE: begin
          if (tr.data[0] !== led_enable)
            `uvm_error("SCB-1", $sformatf(
              "LED_enable mismatch @ 0x4000: got %0b, exp %0b", tr.data[0], led_enable))
        end
        ADDR_DONE: begin
          // SCB-2: Done is a sticky latch (0→1 only); error if it falls 1→0 without reset
          if (done && !tr.data[0])
            `uvm_error("SCB-2", "Done deasserted without reset (1->0 unexpected)")
          done = tr.data[0];
        end
        ADDR_SCRATCH: begin
          if (tr.data !== scratchpad)
            `uvm_error("SCB-3", $sformatf(
              "Scratchpad mismatch @ 0x4008: got 0x%0h, exp 0x%0h", tr.data, scratchpad))
        end
      endcase
    end
  endfunction

  // 7-segment encoding lookup (SPEC §4.4, active-low: 0=segment ON)
  // seg_out[n] = 0 means segment n is lit; bit[7] always 1 when active
  function automatic bit [6:0] seg_encode(int digit);
    case (digit)
      0: return 7'h01;  // segs ON: 1,2,3,4,5,6
      1: return 7'h73;  // segs ON: 2,3
      2: return 7'h48;  // segs ON: 0,1,2,4,5
      3: return 7'h60;  // segs ON: 0,1,2,3,4
      4: return 7'h32;  // segs ON: 0,2,3,6
      5: return 7'h24;  // segs ON: 0,1,3,4,6
      6: return 7'h06;  // segs ON: 0,3,4,5,6
      7: return 7'h71;  // segs ON: 1,2,3
      8: return 7'h00;  // segs ON: all
      9: return 7'h30;  // segs ON: 0,1,2,3,6
      default: begin
        `uvm_error("SCB-5", $sformatf("digit %0d out of range 0-9", digit))
        return 7'h7F;
      end
    endcase
  endfunction

  function void write_led(led_transaction tr);
    automatic int digit_pos;
    automatic int digit_val;
    automatic bit [6:0] exp_seg;
    automatic bit [19:0] display_val;

    // SCB-7: LED disabled — seg_out must not update, skip compare (SPEC §3.4)
    if (!led_enable) return;

    // SCB-8: skip seg_out compare until Done=1 (SPEC §3.5: seg_out indeterminate when Done=0)
    if (!done) return;

    // Skip idle state (all-ones = no digit selected)
    if (tr.sel_out === 6'h3F) return;

    // SCB-6: seg_out[7] must be 1 when any segment is active (SPEC §3.1)
    if (!tr.seg_out[7])
      `uvm_error("SCB-6", $sformatf(
        "seg_out[7]=0 (expected 1) at sel_out=%b seg_out=%b", tr.sel_out, tr.seg_out))

    // SCB-4: decode which digit position is active from sel_out (one-hot active-low)
    digit_pos = -1;
    for (int i = 0; i < 6; i++) begin
      if (!tr.sel_out[i]) begin
        digit_pos = i;
        break;
      end
    end

    if (digit_pos < 0) begin
      `uvm_error("SCB-4", $sformatf(
        "sel_out=%b is not one-hot active-low (no bit=0 found)", tr.sel_out))
      return;
    end

    // SCB-4: golden BCD — apply overflow modulo (SPEC §3.6), then extract digit
    display_val = tr.error_q % 1_000_000;
    begin
      automatic int divisor = 1;
      for (int k = 0; k < digit_pos; k++) divisor *= 10;
      digit_val = int'(display_val / divisor) % 10;
    end

    // SCB-5: look up expected seg_out[6:0] from SPEC §4.4 table
    exp_seg = seg_encode(digit_val);

    if (tr.seg_out[6:0] !== exp_seg)
      `uvm_error("SCB-5", $sformatf(
        "seg_out mismatch @ digit_pos=%0d (digit=%0d): got 7'h%02h exp 7'h%02h | error_q=%0d",
        digit_pos, digit_val, tr.seg_out[6:0], exp_seg, tr.error_q))
    else
      `uvm_info("SCB-5", $sformatf(
        "PASS digit_pos=%0d digit=%0d seg_out=7'h%02h error_q=%0d",
        digit_pos, digit_val, tr.seg_out[6:0], tr.error_q), UVM_MEDIUM)
  endfunction

endclass
