// Phase 3 — environment (agents + scoreboard + virtual sequencer)
class led_env extends uvm_env;
  `uvm_component_utils(led_env)

  apb_agent              apb_agt;
  led_agent              led_agt;
  led_scoreboard         scb;
  led_virtual_sequencer  v_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for led_env", UVM_LOW)
    apb_agt = apb_agent::type_id::create("apb_agt", this);
    led_agt = led_agent::type_id::create("led_agt", this);
    scb     = led_scoreboard::type_id::create("scb", this);
    v_seqr  = led_virtual_sequencer::type_id::create("v_seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    apb_agt.monitor.analysis_port.connect(scb.apb_imp);
    led_agt.monitor.analysis_port.connect(scb.led_imp);
    v_seqr.apb_seqr = apb_agt.sequencer;
    v_seqr.led_seqr = led_agt.sequencer;
  endfunction

endclass
