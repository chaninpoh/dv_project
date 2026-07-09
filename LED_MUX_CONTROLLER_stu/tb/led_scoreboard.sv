// Phase 3 — single scoreboard for all P0 tests (extend SCB logic per test)
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_led)

class led_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(led_scoreboard)

  apb_analysis_imp_apb #(apb_transaction) apb_imp;
  led_analysis_imp_led #(led_transaction) led_imp;

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
    // SCB-1..3, 7..9 added incrementally per P0 test (PLAN §3.4)
  endfunction

  function void write_led(led_transaction tr);
    // SCB-4..6, 8 added incrementally per P0 test (PLAN §3.4)
  endfunction

endclass
