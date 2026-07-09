# FIX — Known errors and resolutions

**Use with:** `PLAN.md` · `pre_PLAN.md`  
**When:** Compile or simulation fails, review gate FAIL, or unexpected warnings block progress.

---

## How to use this file

1. Reproduce the failure on the **Linux VM** (`make dv TESTNAME=<test> SEED=0`).
2. Open `dut_comp.log` and/or `<TESTNAME>_seed_<SEED>_sim.log`.
3. Search this file for a **symptom**, **log keyword**, or **FIX-ID**.
4. Apply the fix; re-run the same command.
5. Prompt the agent: `check logfiles` (do not proceed to the next phase until gate PASS).

**Add new entries** at the bottom when you hit a new error — one row per root cause.

---

## Quick lookup

| FIX-ID | Phase | Symptom / log keyword | Section |
|---|---|---|---|
| FIX-001 | 1 | `test_lib` / duplicate class / already defined | [§FIX-001](#fix-001-test_lib-compiled-twice-via-dutf) |
| FIX-002 | All | VCS / make not found on Windows | [§FIX-002](#fix-002-cannot-run-vcs-on-windows) |
| FIX-016 | All | `run_sim.csh` / `execvp` / `Permission denied` / Error 127 | [§FIX-016](#fix-016-run_simcsh-not-executable) |
| FIX-003 | 1–2 | `uvm_config_db::get failed` / `NOVIF` | [§FIX-003](#fix-003-uvm_config_db-vif-lookup-failed) |
| FIX-004 | 1+ | Phase marker not found in sim log | [§FIX-004](#fix-004-phase-marker-missing-in-sim-log) |
| FIX-005 | 1 | `Error-` / `Syntax error` in `dut_comp.log` | [§FIX-005](#fix-005-vcs-compile-errors) |
| FIX-015 | 1+ | `Error-[DPI-DIFNF]` / `uvm_glob_to_re` not found | [§FIX-015](#fix-015-dpi-difnf-missing--cflags--dvcs) |
| FIX-006 | 1+ | `UVM_ERROR` / `UVM_FATAL` in sim log | [§FIX-006](#fix-006-uvm_error-or-uvm_fatal-in-simulation) |
| FIX-007 | 1 | Wrong test runs / `my_test` instead of gate test | [§FIX-007](#fix-007-wrong-testname-on-make-dv) |
| FIX-008 | 2 | `led_driver` / `reset` vs `rst_n` | [§FIX-008](#fix-008-led_if-reset-signal-name-mismatch) |
| FIX-009 | 1 | `Warning-[PCWM-W]` dp_mux / bin2bcd width | [§FIX-009](#fix-009-pcwm-width-warning-dp_mux--bin2bcd) |
| FIX-010 | 2 | Agent / topology empty; factory missing test | [§FIX-010](#fix-010-factory-or-topology-missing-in-log) |
| FIX-011 | 3 | Scoreboard false fail before `Done==1` | [§FIX-011](#fix-011-scoreboard-compares-before-done) |
| FIX-012 | 3 | SVA assertion failure / `dut_sva.rpt` | [§FIX-012](#fix-012-sva-assertion-failure) |
| FIX-013 | 4 | `regress_p0.sh` permission denied | [§FIX-013](#fix-013-regress_p0sh-not-executable) |
| FIX-014 | — | Excel `PermissionError` generating testplan | [§FIX-014](#fix-014-excel-testplan-permission-denied) |

---

## Phase 1 — Testbench top

### FIX-001: `test_lib` compiled twice via `dut.f`

| | |
|---|---|
| **Symptom** | Compile error: class/type already defined; `test_lib.svh` parsed twice |
| **Log** | `dut_comp.log`: duplicate `phase1_tb_top_test` or "Identifier previously declared" |
| **Cause** | `test_lib.svh` or `*_test.sv` listed in `dut.f` **and** `` `include "test_lib.svh" `` in `top_tb.sv` |
| **Fix** | Remove `test_lib.svh` and all `*_test.sv` from `tb/dut.f`. Keep only: RTL, interfaces, `top_tb.sv`. Include tests in `top_tb` **after** `import uvm_pkg::*`. |
| **Verify** | `grep test_lib dut.f` → no match; compile clean |

### FIX-002: Cannot run VCS on Windows

| | |
|---|---|
| **Symptom** | `vcs: command not found` or agent cannot run simulation from Cursor on Windows |
| **Cause** | Synopsys VCS is licensed on the **course Linux VM** only |
| **Fix** | Run `source proj1.setup && make dv TESTNAME=<test> SEED=0` on the VM. Sync project via git/shared folder. Prompt agent `check logfiles` after run. |
| **Verify** | Logs appear under `LED_MUX_CONTROLLER_stu/sim/` |

### FIX-016: `run_sim.csh` not executable

| | |
|---|---|
| **Symptom** | `make dv` fails immediately; no `dut_comp.log` created |
| **Log** | `make: execvp: .../run_sim.csh: Permission denied` and `Error 127` on `run_dv` |
| **Cause** | `sim/run_sim.csh` lost execute permission (common after sync from Windows/git) |
| **Fix** | From `sim/`: `chmod +x run_sim.csh` |
| **Also** | One-time per VM session: `chmod +x run_sim.csh check_phase*_gate.sh` |
| **Note** | `sim/makefile` invokes `csh run_sim.csh` so `make dv` works even without `+x`; `chmod` still needed if you run `./run_sim.csh` directly |
| **Verify** | `make dv TESTNAME=<test> SEED=0` starts; `vcs` line appears in terminal or `dut_comp.log` |

### FIX-003: `uvm_config_db` vif lookup failed

| | |
|---|---|
| **Symptom** | `UVM_FATAL` / `UVM_ERROR`: `uvm_config_db::get failed` for `dut_vif` or `vif` |
| **Log** | `*_sim.log`: `NOVIF` or get failed in driver/monitor `build_phase` |
| **Cause** | `top_tb` `config_db` path or key does not match agent `get()` path |
| **Fix** | Align paths, e.g. `uvm_test_top.env.apb_agt*` and key `dut_vif` everywhere. Set in `top_tb` **before** `run_test()`. |
| **Verify** | No `get failed` after reset; optional `+UVM_CONFIG_DB_TRACE` |

### FIX-004: Phase marker missing in sim log

| | |
|---|---|
| **Symptom** | Gate FAIL: `PHASE 1 : testbench top` not found |
| **Log** | No `UVM_INFO` with marker string; test ended too early |
| **Cause** | `run_phase` dropped objection before `#delay`; wrong test class; typo in marker string |
| **Fix** | Ensure `` `uvm_info("PHASE1_TB_TOP", "PHASE 1 : testbench top bring-up complete", UVM_LOW) `` runs after reset (e.g. `#1200ns`). `TESTNAME` must match test class name. |
| **Verify** | `grep "PHASE 1 : testbench top" *_sim.log` |

### FIX-005: VCS compile errors

| | |
|---|---|
| **Symptom** | Gate FAIL; `Error-[...]` or `Syntax error` in `dut_comp.log` |
| **Fix** | Read first error in log (not warnings). Common: missing file in `dut.f`, package not imported, interface port mismatch to DUT, **missing `-CFLAGS -DVCS`** (see FIX-015). Fix RTL/TB; `make clean` then `make dv ...`. |
| **Verify** | `grep -iE "error-|syntax error" dut_comp.log` → empty |

### FIX-015: DPI-DIFNF — missing `-CFLAGS -DVCS`

| | |
|---|---|
| **Symptom** | Elaborate/compile stops with DPI import function not found |
| **Log** | `Error-[DPI-DIFNF] DPI import function not found` |
| **Location** | `uvm_resource.svh` line ~386 — function **`uvm_glob_to_re`** |
| **Cause** | VCS `vcs` command missing **`-CFLAGS -DVCS`**. UVM 1.2 DPI C code for VCS is compiled only when the `VCS` macro is defined for the C++ compiler. |
| **Fix** | Add to every **compile/elab** `vcs` invocation (before or after filelist): |

```bash
vcs -full64 -sverilog ... -file $ROOT/tb/dut.f -CFLAGS -DVCS
```

| | |
|---|---|
| **This project** | `run_sim.csh` appends `-CFLAGS -DVCS` when using `make dv`. If you run raw `vcs` by hand, include the flag. |
| **Verify** | `grep CFLAGS dut_comp.log` shows `-CFLAGS -DVCS`; compile completes; no `DPI-DIFNF` |

### FIX-006: `UVM_ERROR` or `UVM_FATAL` in simulation

| | |
|---|---|
| **Symptom** | Gate FAIL; report summary shows `UVM_ERROR > 0` |
| **Fix** | Scroll up in sim log to first `UVM_ERROR` line — note component and message. See phase-specific fixes (FIX-003, FIX-008, FIX-011). |
| **Verify** | `UVM_ERROR : 0` and `UVM_FATAL : 0` in report summary |

### FIX-007: Wrong TESTNAME on `make dv`

| | |
|---|---|
| **Symptom** | Log shows `Running test my_test` instead of `phase1_tb_top_test` |
| **Cause** | `makefile` default `TESTNAME` or command omitted override |
| **Fix** | Always pass explicitly: `make dv TESTNAME=phase1_tb_top_test SEED=0` |
| **Verify** | Sim log line `[RNTST] Running test phase1_tb_top_test...` |

### FIX-009: PCWM width warning (`dp_mux` / `bin2bcd`)

| | |
|---|---|
| **Symptom** | `Warning-[PCWM-W]` 6-bit connected to 4-bit `dig0`..`dig5` |
| **Cause** | RTL width mismatch in student `dp_mux.sv` (known) |
| **Fix** | **Non-blocking for Phase 1 gate** if no `Error-`. Optional: slice digits `[3:0]` in `dp_mux.sv` when connecting to `bin2bcd`. |
| **Verify** | Compile completes; sim runs |

---

## Phase 2 — UVM agents

### FIX-008: `led_if` reset signal name mismatch

| | |
|---|---|
| **Symptom** | Compile error: `reset` not a member of `led_if`; or sim hang |
| **Cause** | `led_driver.sv` uses `dut_vif.reset`; `led_if` uses `rst_n` |
| **Fix** | Standardize on `rst_n` in `led_if.sv` and update `led_driver` / `led_monitor` to `dut_vif.rst_n`. |
| **Verify** | Compile clean; LED agent build prints in log |

### FIX-010: Factory or topology missing in log

| | |
|---|---|
| **Symptom** | Phase 2 gate: no `factory.print()` or agent paths in log |
| **Cause** | `end_of_elaboration_phase` not implemented in `base_test`; test does not extend `base_test` |
| **Fix** | Add `factory = uvm_factory::get(); factory.print(); uvm_top.print_topology();` in `base_test`. `phase2_agent_sanity_test` must extend `base_test`. |
| **Verify** | Log contains `uvm_factory` and `apb_agt` / `led_agt` |

---

## Phase 3 — P0 tests, scoreboard, SVA

### FIX-011: Scoreboard compares before `Done`

| | |
|---|---|
| **Symptom** | `UVM_ERROR` from `led_scoreboard` — seg_out mismatch while display updating |
| **Cause** | Compare ran when `Done==0` (SPEC: `seg_out` indeterminate) |
| **Fix** | Implement SCB-8 gating in `led_scoreboard`: skip `seg_out` compare until APB read shows `Done==1`. |
| **Verify** | `led_decimal_42_test` passes after poll Done sequence |

### FIX-012: SVA assertion failure

| | |
|---|---|
| **Symptom** | Assertion failures in sim log or `dut_sva.rpt` |
| **Fix** | Match property name to TESTPLAN §0.3. Check `bind` port wiring in `top_tb`. Ensure `disable iff (!rst_n)`. Distinguish RTL bug vs stimulus timing (C-4 hold, C-5 latency). |
| **Verify** | Assertion summary: 0 failures for enabled properties |

---

## Phase 4 — P0 regression

### FIX-013: `regress_p0.sh` not executable

| | |
|---|---|
| **Symptom** | `Permission denied` running `./regress_p0.sh` |
| **Fix** | `chmod +x regress_p0.sh` from `sim/` directory |
| **Verify** | Script runs all 11 `make dv` lines |

---

## Tooling / docs (any phase)

### FIX-014: Excel testplan permission denied

| | |
|---|---|
| **Symptom** | `PermissionError` when running `generate_testplan.py` |
| **Cause** | `LED_MUX_CONTROLLER_testplan.xlsx` open in Excel |
| **Fix** | Close Excel file; re-run script, or output to alternate name: `--tier p0` → `_p0.xlsx` |
| **Verify** | Script exits 0; file updated |

---

## Adding a new fix (template)

Copy this block when you document a new issue:

```markdown
### FIX-0XX: Short title

| | |
|---|---|
| **Symptom** | What you see |
| **Log** | grep pattern / file |
| **Cause** | Root cause |
| **Fix** | Steps |
| **Verify** | How to confirm resolved |
| **Phase** | 1 / 2 / 3 / 4 / 5 |
```

---

*Last updated: FIX-016 — `run_sim.csh` permission denied / Error 127. Extend as new failures are found.*
