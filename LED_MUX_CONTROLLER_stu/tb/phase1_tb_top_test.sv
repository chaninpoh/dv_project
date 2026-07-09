// Phase 1 gate test — minimal UVM test, no env required
class phase1_tb_top_test extends uvm_test;
  `uvm_component_utils(phase1_tb_top_test)

  localparam time UVM_PHASE_DRAIN_TIME = 1000ns;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Wait past reset release (1000 ns) plus margin
    #1200ns;
    `uvm_info("PHASE1_TB_TOP", "PHASE 1 : testbench top bring-up complete", UVM_LOW)
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, UVM_PHASE_DRAIN_TIME);
  endtask

endclass
