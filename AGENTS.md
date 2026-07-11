# CLAUDE.md — Project Rules for LED MUX Controller DV

These rules are **mandatory** for every agent session working on this project.

---

## Rule 1 — SPEC is the only source of truth for DUT behavior

**DO NOT** read RTL source files (`src/`, `*.sv` under `src/`) to understand DUT behavior, register values, timing, or expected outputs.

**DO** derive all test stimulus and expected values exclusively from SPEC documents:

- `SPEC.md`
- `ARCHITECTURE.md`
- `TESTPLAN.md`
- `LED_MUX_CONTROLLER_testplan.xlsx`

If the SPEC is ambiguous, ask the user for clarification. Do not inspect RTL as a shortcut.

---

## Rule 2 — One test at a time, always run simulation between tests

**Always** implement exactly **one** test, then run simulation and confirm it passes before starting the next test.

Never batch-create multiple tests, sequences, or scoreboard extensions without a green gate run in between.

Workflow per test:
1. Implement the test (sequence + test class + scoreboard/SVA if needed)
2. Run: `cd /home/pohsl/ai_dv_project/dv_project/LED_MUX_CONTROLLER_stu && source proj1.setup && cd sim && make dv TESTNAME=<testname> SEED=0`
3. Read logs and confirm gate PASS (zero UVM_ERROR, zero UVM_FATAL, phase marker present)
4. Only then proceed to the next test

---

## Rule 3 — Bug tagging: TB_BUG vs BUG

| Category | Tag | Description |
|---|---|---|
| Testbench defect | `TB_BUG-xxx` | Issue is in the testbench (driver, monitor, sequence, scoreboard, SVA wiring) |
| Design/DUT defect | `BUG-xxx` | Issue is in the DUT RTL (`src/`) |

- Document both categories in **`FIX.md`** in separate sections.
- Never mix testbench issues with DUT bugs under the same tag.

---

## Rule 4 — Do not fix DUT bugs in the testbench without confirmation

If a simulation failure is suspected to be a DUT (RTL) bug:

1. Document it in `FIX.md` under "Design Bugs" with status **OPEN**.
2. **Do not** adjust scoreboard expected values, SVA thresholds, or test stimulus to hide the failure.
3. **Do not** edit any testbench file to work around a DUT issue until the user explicitly confirms it is a DUT bug.
4. Flag it to the user and wait for confirmation before any workaround.

---

## Rule 5 — Correct simulation command

Always use this exact sequence to run simulation:

```bash
cd /home/pohsl/ai_dv_project/dv_project/LED_MUX_CONTROLLER_stu
source proj1.setup
cd sim
make dv TESTNAME=<testname> SEED=0
```

**Do NOT** run `source proj1.setup` from inside `sim/` or from any other directory — it will fail with `run_sim.csh: No such file or directory`.

---

## Rule 6 — Gate criteria (all phases)

A test is considered **passing** only when ALL of these are true after `make dv`:

| Check | Command |
|---|---|
| No compile errors | `grep -iE "error-\|syntax error" dut_comp.log` → empty |
| Phase marker present | `grep "PHASE 3 : P0 <testname>" <sim_log>` → match |
| Zero UVM_ERROR | `grep -c UVM_ERROR <sim_log>` → 0 |
| Zero UVM_FATAL | `grep -c UVM_FATAL <sim_log>` → 0 |

---

## Rule 7 — Virtual sequencer pattern (all P0 tests)

- All virtual sequences use `uvm_declare_p_sequencer(led_virtual_sequencer)` and start sub-sequences via `p_sequencer.apb_seqr` / `p_sequencer.led_seqr`.
- Tests only reference `env.v_seqr` — no physical sequencer handles inside test classes.
- `led_virtual_sequencer.sv` must be included **before** `led_env.sv` in `test_lib.svh`.

---

## Rule 8 — Files to read for context (reference order)

1. `FIX.md` — known bugs and resolutions
2. `PLAN.md` — phase-by-phase implementation plan
3. `pre_PLAN.md` — reusable project template and patterns
4. `SPEC.md`, `ARCHITECTURE.md`, `TESTPLAN.md` — DUT behavior source of truth
5. `LED_MUX_CONTROLLER_testplan.xlsx` — P0 test list and expected behavior

**Never read `src/*.sv` or any RTL file to understand DUT behavior.**

---

## Rule 9 — Testbench file organisation

All files under `tb/` must follow this layout:

| Folder | Contents |
|---|---|
| `tb/test/` | All UVM test classes (`*_test.sv`, `base_test.sv`) |
| `tb/sequences/` | All sequence and virtual-sequence files (`*_seq.sv`, `*_vseq.sv`) |
| `tb/apb_agent/` | APB agent components (driver, monitor, sequencer, transaction, pkg) |
| `tb/led_agent/` | LED agent components |
| `tb/sva/` | SVA module (`led_mux_sva.sv`) |
| `tb/` (root) | Infrastructure only: `top_tb.sv`, `test_lib.svh`, `led_env.sv`, `led_scoreboard.sv`, `led_virtual_sequencer.sv`, `led_tb_pkg.svh`, `dut.f` |

`led_tb_pkg.svh` contains (in order): `led_scoreboard.sv`, `led_virtual_sequencer.sv`, then all `sequences/*.sv` files.
`test_lib.svh` contains (in order): `led_env.sv`, then all `test/*.sv` files. No sequences.

**When adding a new test:** place the `.sv` file in `tb/test/` and add `` `include "test/<filename>.sv" `` to `test_lib.svh`.

**When adding a new sequence:** place the `.sv` file in `tb/sequences/` and add `` `include "sequences/<filename>.sv" `` to `led_tb_pkg.svh` — **NOT** to `test_lib.svh`.

---

## Rule 10 — smoke_test policy

`smoke_test` is **not** a regression test. It is a TB-change gate.

| Situation | Action |
|---|---|
| Phase 5 P0 regression (`./regress_p0.sh`) | **Do NOT** include `smoke_test` — it is excluded from `P0_TESTS` in the script |
| Any file under `tb/` is created or modified | Run `make dv TESTNAME=smoke_test SEED=0` and confirm gate PASS before proceeding |
| No TB files changed | Do not run `smoke_test` unnecessarily |

**Never add `smoke_test` back to `regress_p0.sh`.** If a future regression script is created, apply the same exclusion.
