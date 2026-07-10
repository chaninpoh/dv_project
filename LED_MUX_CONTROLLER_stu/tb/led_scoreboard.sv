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
          if (tr.data !== 32'(done))
            `uvm_error("SCB-2", $sformatf(
              "Done mismatch @ 0x4004: got 0x%0h, exp 0x%0h", tr.data, 32'(done)))
        end
        ADDR_SCRATCH: begin
          if (tr.data !== scratchpad)
            `uvm_error("SCB-3", $sformatf(
              "Scratchpad mismatch @ 0x4008: got 0x%0h, exp 0x%0h", tr.data, scratchpad))
        end
      endcase
    end
  endfunction

  function void write_led(led_transaction tr);
    // SCB-4..6, 8 added incrementally per P0 test (PLAN §3.4)
  endfunction

endclass
