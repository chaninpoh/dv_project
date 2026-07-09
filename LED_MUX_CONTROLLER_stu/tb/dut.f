// Phase 2 filelist — RTL + agent packages + testbench top (no test_lib / *_test.sv)
+incdir+../src
+incdir+../src/AMBA/APB
../src/AMBA/APB/APB_Slave.sv
../src/bin2bcd.v
../src/LED_mux.v
../src/dp_mux.sv
../src/watchdog_mod.sv
../src/dut.sv

+incdir+../tb
+incdir+../tb/apb_agent
+incdir+../tb/led_agent
+incdir+../tb/sequences
+incdir+../tb/sva
../tb/apb_agent/apb_if.sv
../tb/led_agent/led_if.sv
../tb/sva/led_mux_sva.sv
../tb/apb_agent/apb_agent_pkg.svh
../tb/led_agent/led_agent_pkg.svh
../tb/led_tb_pkg.svh
../tb/top_tb.sv
