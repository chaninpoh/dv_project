// Phase 2 — base test: env hook + factory / topology debug
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  uvm_factory factory;
  led_env     env;

  localparam time UVM_PHASE_DRAIN_TIME = 1000ns;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for base_test", UVM_LOW)

    uvm_config_db#(uvm_active_passive_enum)::set(
      this, "env.apb_agt", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(
      this, "env.led_agt", "is_active", UVM_ACTIVE);

    env = led_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    factory = uvm_factory::get();
    factory.print();
    uvm_top.print_topology();
  endfunction

  function void set_run_phase_drain_time(uvm_phase phase);
    phase.phase_done.set_drain_time(this, UVM_PHASE_DRAIN_TIME);
  endfunction

endclass
