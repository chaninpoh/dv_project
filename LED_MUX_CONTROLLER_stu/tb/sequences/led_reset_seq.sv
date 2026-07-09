// P0 E07 / E02 — assert and deassert DUT reset via led_if (TESTPLAN §0.1)
class led_reset_seq extends uvm_sequence #(led_transaction);
  `uvm_object_utils(led_reset_seq)

  virtual led_if vif;
  time hold_time = 100ns;  // SPEC: reset hold >= 100 ns

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(virtual led_if)::get(
          null, "uvm_test_top.env.led_agt", "dut_vif", vif))
      `uvm_fatal(get_type_name(), "uvm_config_db::get failed for led_if dut_vif")

    `uvm_info(get_type_name(), "Asserting rst_n=0", UVM_MEDIUM)
    vif.rst_n = 0;
    #hold_time;

    `uvm_info(get_type_name(), "Deasserting rst_n=1", UVM_MEDIUM)
    vif.rst_n = 1;
    @(posedge vif.clk);
  endtask

endclass
