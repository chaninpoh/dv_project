// Phase 1 filelist — minimal RTL + testbench top (no agents yet)
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
../tb/apb_agent/apb_if.sv
../tb/led_agent/led_if.sv
../tb/test_lib.svh
../tb/top_tb.sv
