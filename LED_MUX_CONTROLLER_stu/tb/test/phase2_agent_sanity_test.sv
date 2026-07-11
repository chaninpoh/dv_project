// Phase 2 gate test — both agents factory-built and visible in topology
class phase2_agent_sanity_test extends base_test;
  `uvm_component_utils(phase2_agent_sanity_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("PHASE1_TB_TOP", "PHASE 1 : testbench top bring-up complete", UVM_LOW)

    if (env.apb_agt == null)
      `uvm_error(get_type_name(), "apb_agent not instantiated in env")
    else
      `uvm_info(get_type_name(), "PHASE 2 : apb_agent instantiated", UVM_LOW)

    if (env.led_agt == null)
      `uvm_error(get_type_name(), "led_agent not instantiated in env")
    else
      `uvm_info(get_type_name(), "PHASE 2 : led_agent instantiated", UVM_LOW)

    `uvm_info("PHASE2_AGENTS", "PHASE 2 : uvm agents integration complete", UVM_LOW)

    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask

endclass
