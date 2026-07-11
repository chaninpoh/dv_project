# Verification PLAN — LED MUX Controller

**Template source:** `pre_PLAN.md` (reusable skeleton for new projects)  
**References:** SPEC.md · ARCHITECTURE.md · TESTPLAN.md · **FIX.md** · **CLAUDE.md**  
**Tool:** Synopsys VCS + UVM 1.2  
**Project tree:** `LED_MUX_CONTROLLER_stu/` (RTL `src/`, testbench `tb/`, simulation `sim/`)

> **Agent rules:** See `CLAUDE.md` for mandatory project rules (SPEC-only policy, one-test-at-a-time, TB_BUG vs BUG tagging, sim command, gate criteria).

This document defines verification **phases** in build order. Each phase has one clear goal, step-by-step tasks, testable acceptance criteria, Makefile targets, and a **review gate** before the next phase starts.

---

## Agent / user workflow (mandatory)

**VCS is available on this Linux machine. The agent runs compile and simulation directly, then reads the log and reports gate PASS/FAIL.**

**If compile or simulation fails:** check **`FIX.md`** for known errors and fixes.

### How it works (current workflow)

Every phase follows this flow — the agent handles compile, sim, and gate check without waiting for a user prompt:

1. **Agent** creates or updates source files.
2. **Agent** runs `make dv TESTNAME=<test> SEED=0` in the terminal (from `LED_MUX_CONTROLLER_stu/sim/` with `proj1.setup` sourced).
3. **Agent** reads `dut_comp.log` and `<TESTNAME>_seed_0_sim.log`, applies the phase gate checklist, and reports **PASS** or **FAIL**.
4. On **PASS**: agent proceeds to the next step or asks which test to implement next.
5. On **FAIL**: agent diagnoses the error from the log, applies a fix, and re-runs.

### Failure notification — Claude only

When a **new** failure is found the agent posts this block in the conversation and stops:

```
⚠ NEW FAILURE DETECTED
Test    : <testname>
Bug tag : <BUG-xxx or TB_BUG-xxx>
Symptom : <one-line description>
Log ref : sim/<testname>_seed_0_sim.log @ <timestamp>
Detail  : <got vs expected>
Action  : Awaiting user confirmation before proceeding.
```

No external email or webhook is used. Notification is through Claude only. The bug is also documented in `FIX.md` with status **OPEN** before stopping.

### Standard run command (this project)

```bash
cd /home/pohsl/ai_dv_project/dv_project/LED_MUX_CONTROLLER_stu
source proj1.setup
cd sim
make dv TESTNAME=<testname> SEED=0
```

### Agent gate check (after each run)

Passing signature — all must be true:

| Check | Command |
|---|---|
| Phase marker present | `grep "PHASE 3 : P0 <testname>" <sim_log>` |
| Zero UVM_ERROR | `grep -c UVM_ERROR <sim_log>` → 0 |
| Zero UVM_FATAL | `grep -c UVM_FATAL <sim_log>` → 0 |
| No compile errors | `grep -iE "error-\|syntax error" dut_comp.log` → no match |

### Agent / user roles (summary)

| Step | Who | Action |
|---|---|---|
| 1 | **Agent** | Create or update TB/UVM/SVA source files |
| 2 | **Agent** | Run `make dv TESTNAME=<test> SEED=0` in the terminal |
| 3 | **Agent** | Read logs; check gate criteria; report PASS/FAIL |
| 4 | **Agent** | On PASS: proceed to next step; on FAIL: fix and re-run |
| 5 | **User** | Review results; approve proceeding to next test |

Log files the agent reads:

| Pattern | Example |
|---|---|
| Compile | `sim/dut_comp.log` |
| Simulation | `sim/<TESTNAME>_seed_<SEED>_sim.log` |
| Fixes | **`FIX.md`** |

### Standard run command (this project)

All phases use the course makefile wrapper:

```bash
make dv TESTNAME=<testname> SEED=0
```

`make dv` invokes `run_sim.csh` (compile + elaborate + simulate). Override `TESTNAME` and `SEED` per test.

### UVM test conventions (all phases)

Every UVM test **`run_phase`** must set a **1000 ns phase drain time** after dropping the run-phase objection so monitors, drivers, and scoreboard TLM paths can flush before the phase ends.

| Phase | Where to set | Value |
|---|---|---|
| 1 | `phase1_tb_top_test` (extends `uvm_test`) | `1000ns` via `localparam UVM_PHASE_DRAIN_TIME` |
| 2–5 | Tests extending `base_test` | Call `set_run_phase_drain_time(phase)` after `drop_objection` (`base_test` defines `UVM_PHASE_DRAIN_TIME = 1000ns`) |

**Required pattern** (after all stimulus / checks in `run_phase`):

```systemverilog
phase.drop_objection(this);
phase.phase_done.set_drain_time(this, 1000ns);   // Phase 1 standalone tests

// OR, for tests extending base_test:
phase.drop_objection(this);
set_run_phase_drain_time(phase);
```

**`base_test` helper** (`tb/base_test.sv`):

```systemverilog
localparam time UVM_PHASE_DRAIN_TIME = 1000ns;

function void set_run_phase_drain_time(uvm_phase phase);
  phase.phase_done.set_drain_time(this, UVM_PHASE_DRAIN_TIME);
endfunction
```

Do **not** call `super` in UVM phase methods (project convention). Phase 3+ P0 tests inherit drain time via `set_run_phase_drain_time(phase)` at the end of every `run_phase`.

---

## Phase overview

| Phase | Name | Single goal | Gate test |
|---|---|---|---|
| **1** | Testbench top | Static `top_tb` instantiates DUT + interfaces, drives clk/rst, publishes virtual interfaces, and starts UVM | `phase1_tb_top_test` |
| **2** | UVM agents | `base_test` + incremental agent integration; factory topology dump; both agents active in env | `phase2_agent_sanity_test` |
| **3** | P0 tests + checkers | Implement all 11 P0 tests from `LED_MUX_CONTROLLER_testplan.xlsx` feature-by-feature; one `led_scoreboard`, one `led_mux_sva` bind file | Per-test gate → `regress_p0` |
| **4** | P0 regression sign-off | All 11 P0 tests pass via `./regress_p0.sh` | `regress_p0` clean logs |
| **5** | Coverage closure | P1 tests + `random_regression_test`; functional/code coverage annotated | TESTPLAN Excel |

> **Phases 1–4 are detailed below.** Phase 5 follows the same gate pattern. Do not start Phase 3 until Phase 2 review gate passes.

---

## Phase 1 — Testbench top

### Goal

**Create a compilable, elaboratable static testbench top (`top_tb`) that instantiates the DUT and both virtual interfaces, generates clock and reset, places interface handles in `uvm_config_db`, and runs a minimal UVM test that proves the top is alive.**

### Step-by-step tasks

| Step | Task | Output file(s) |
|---|---|---|
| 1.1 | Source `proj1.setup` from `LED_MUX_CONTROLLER_stu/` (`ROOT`, `MODULE`, `UVM_HOME`, …) | Environment variables set |
| 1.2 | Create / update **`apb_if.sv`** — APB signals per SPEC §4.2 | `tb/apb_agent/apb_if.sv` (exists) |
| 1.3 | Create / update **`led_if.sv`** — `clk`, `rst_n`, `error_q`, `sel_out`, `seg_out` per SPEC §4.1 | `tb/led_agent/led_if.sv` (exists) |
| 1.4 | Instantiate **DUT** (`dut.sv` / `design.f`) inside `top_tb` | `tb/top_tb.sv` |
| 1.5 | Instantiate **`apb_if`** and **`led_if`**; connect DUT ports to interfaces | `tb/top_tb.sv` |
| 1.6 | Add **clock** generator (e.g. 10 ns period → 50 MHz equivalent in sim) | `tb/top_tb.sv` |
| 1.7 | Add **reset** sequence: assert `rst_n=0`, hold ≥ 100 ns, deassert | `tb/top_tb.sv` |
| 1.8 | In `initial` block: `uvm_config_db#(virtual apb_if)::set(...)` and `uvm_config_db#(virtual led_if)::set(...)` | `tb/top_tb.sv` |
| 1.9 | Call **`run_test()`** (no hard-coded test name in `top_tb`) | `tb/top_tb.sv` |
| 1.10 | Create **`phase1_tb_top_test`** — empty env optional; `run_phase` prints phase marker | `tb/phase1_tb_top_test.sv` |
| 1.11 | Add test to **`test_lib.svh`** only; **`include` in `top_tb.sv` after `import uvm_pkg::*`** — **do not** list `test_lib.svh` or `*_test.sv` in **`dut.f`** | `tb/test_lib.svh`, `tb/top_tb.sv` |
| 1.12 | **Agent prompts user** to confirm run command: `make dv TESTNAME=phase1_tb_top_test SEED=0` | User verifies against `sim/makefile` |
| 1.13 | **User runs** confirmed command on VM | `dut_comp.log`, `phase1_tb_top_test_seed_0_sim.log` |
| 1.14 | **User prompts** log check; agent runs **review gate** (§1.4) | Gate PASS / FAIL |

### Phase 1 marker (required in simulation log)

The Phase 1 test **must** emit this exact substring (case-sensitive) in the sim log:

```text
PHASE 1 : testbench top
```

Recommended SystemVerilog:

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  #1200ns;  // past reset release
  `uvm_info("PHASE1_TB_TOP", "PHASE 1 : testbench top bring-up complete", UVM_LOW)
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this, 1000ns);
endtask
```

The review gate searches for `PHASE 1 : testbench top` (prefix match).

### Run command — confirm before execute

**Agent prints; user confirms against `sim/makefile`:**

```text
Please confirm the Phase 1 run command:
  cd LED_MUX_CONTROLLER_stu && source proj1.setup && cd sim
  make dv TESTNAME=phase1_tb_top_test SEED=0
Expected logs: dut_comp.log, phase1_tb_top_test_seed_0_sim.log
After run, prompt: check logfiles
```

### Acceptance criteria (testable)

| ID | Criterion | Input | Expected output / behaviour |
|---|---|---|---|
| AC-P1-01 | Compile succeeds | `make dv TESTNAME=phase1_tb_top_test SEED=0` | `dut_comp.log` exists; exit code `0` |
| AC-P1-02 | No compile errors | `dut_comp.log` | No lines matching `Error-`, `Syntax error`, or `*E` (VCS error); no duplicate-type errors from `test_lib` in `dut.f` |
| AC-P1-03 | Elaboration produces simv | `make dv TESTNAME=phase1_tb_top_test SEED=0` | `dut_simv` (or `${MODULE}_simv`) binary created |
| AC-P1-04 | Simulation runs | `make dv TESTNAME=phase1_tb_top_test SEED=0` | `phase1_tb_top_test_seed_0_sim.log` exists; exit code `0` |
| AC-P1-05 | Phase marker present | Sim log file | Line contains `UVM_INFO` and `PHASE 1 : testbench top` |
| AC-P1-06 | No UVM errors | Sim log file | Zero occurrences of `UVM_ERROR` |
| AC-P1-07 | No fatal / simulator errors | Sim log file | Zero occurrences of `UVM_FATAL`, `Error-[`, `*Error*` |
| AC-P1-08 | Reset deasserted | Waveform or led_if sample after reset | `rst_n == 1` before `run_test` completes |
| AC-P1-09 | DUT not X on bus after reset | Optional waveform check | `sel_out`, `seg_out` not `X` after 10 cycles post-reset |
| AC-P1-10 | config_db published | Sim log (optional `+UVM_CONFIG_DB_TRACE`) | No `UVM_FATAL` / `NOVIF` for virtual interface lookup in Phase 1 test |

### Files created / modified (Phase 1 minimum)

```text
LED_MUX_CONTROLLER_stu/
  tb/
    top_tb.sv              # import uvm_pkg::*; `include "test_lib.svh"; clk, rst, DUT, config_db, run_test()
    phase1_tb_top_test.sv  # Phase 1 gate test (pulled in via test_lib only)
    test_lib.svh           # `include phase1_tb_top_test — NOT in dut.f
    dut.f                  # RTL + interfaces + top_tb.sv only (no test_lib)
  sim/
    makefile               # compile / run / gate targets (see §1.3)
```

**`top_tb.sv` include order (required):**

```systemverilog
`include "uvm_macros.svh"

module top_tb;
  import uvm_pkg::*;
  `include "test_lib.svh"   // after import; never compile test_lib via dut.f

  // ... interfaces, DUT, clk, rst, config_db, run_test()
endmodule
```

---

## 1.3 Makefile — VCS compile, elaborate, and run

Primary target for all phases: **`make dv TESTNAME=<testname> SEED=0`**.

`sim/makefile` maps `dv` → `run_dv` → `run_sim.csh dv ${MODULE} ${TESTNAME} ${SEED}` (compile + elaborate + sim in one step).

Optional gate wrapper (runs sim + local shell check):

```makefile
phase1: run_dv gate1
```

### Variables

```makefile
# LED_MUX_CONTROLLER_stu/sim/makefile (excerpt)

TESTNAME ?= phase1_tb_top_test
SEED     ?= 0

MODULE    = dut
MODULE_TB = top_tb
UVM_HOME ?= $(shell echo $$UVM_HOME)

COMP_LOG  = $(MODULE)_comp.log
SIM_LOG   = $(TESTNAME)_seed_$(SEED)_sim.log
SIMV      = $(MODULE)_simv

FLIST     = $(ROOT)/tb/$(MODULE).f

VCS_COMPILE_OPTS = -full64 -sverilog +v2k +vcs+lic+wait +vcs+flush+all \
                   -debug_access+all -kdb -debug_report \
                   -timescale=1ns/1ps \
                   -ntb_opts uvm-1.2 \
                   +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
                   -top $(MODULE_TB) -o $(SIMV) \
                   -l $(COMP_LOG) \
                   -CFLAGS -DVCS

VCS_RUN_OPTS = +UVM_TESTNAME=$(TESTNAME) +ntb_random_seed=$(SEED) \
               -l $(SIM_LOG) +UVM_NO_RELNOTES
```

### Target (a) — Compile + elaborate

Single `vcs` invocation (compile and elaborate); log → **`dut_comp.log`**.

```makefile
compile:
	vcs $(VCS_COMPILE_OPTS) -file $(FLIST)
```

**Equivalent command line (preferred):**

```bash
cd LED_MUX_CONTROLLER_stu/sim
source ../proj1.setup
make dv TESTNAME=phase1_tb_top_test SEED=0
```

**Raw VCS command (reference):**

```bash
vcs -full64 -sverilog +v2k +vcs+lic+wait +vcs+flush+all \
    -debug_access+all -kdb -debug_report \
    -timescale=1ns/1ps -ntb_opts uvm-1.2 \
    +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
    -top top_tb -o dut_simv \
    -l dut_comp.log \
    -file $ROOT/tb/dut.f \
    -CFLAGS -DVCS
```

### Target (b) — Run simulation

Requires `dut_simv` from `compile`. Log → **`$(TESTNAME)_seed_$(SEED)_sim.log`**.

```makefile
run: compile
	./$(SIMV) $(VCS_RUN_OPTS)
```

**Equivalent command line:**

```bash
make dv TESTNAME=phase1_tb_top_test SEED=0
```

**Raw simv command (reference):**

```bash
./dut_simv +UVM_TESTNAME=phase1_tb_top_test +ntb_random_seed=0 \
           -l phase1_tb_top_test_seed_0_sim.log +UVM_NO_RELNOTES
```

### Combined target (course style)

Matches existing `make dv` wrapper:

```makefile
dv: compile run
```

**Sample session:**

```bash
cd LED_MUX_CONTROLLER_stu
source proj1.setup
cd sim
make clean
make dv TESTNAME=phase1_tb_top_test SEED=0
```

Or via existing csh wrapper:

```bash
cd LED_MUX_CONTROLLER_stu/sim
source ../proj1.setup
make run_dv TESTNAME=phase1_tb_top_test SEED=0
```

### Log file naming (detected by review gate)

| Pattern | Example | When |
|---|---|---|
| `$(MODULE)_comp.log` | `dut_comp.log` | Compile + elaborate |
| `$(TESTNAME)_seed_$(SEED)_sim.log` | `phase1_tb_top_test_seed_0_sim.log` | Simulation |
| `*_sim.log` | `smoke_test_seed_0_sim.log` | Any test run |
| `sim.log` | `sim.log` | Optional alias if you add a symlink rule |

---

## 1.4 Review gate — Phase 1

**Do not proceed to Phase 2 until every check below passes.**

### Gate checklist

| # | Check | How to verify |
|---|---|---|
| G1 | Compile log exists | `dut_comp.log` or `*_comp.log` present |
| G2 | Sim log exists | `phase1_tb_top_test_seed_0_sim.log` or `*_sim.log` present |
| G3 | Phase marker | `grep -q "PHASE 1 : testbench top" <sim_log>` |
| G4 | No `UVM_ERROR` in sim log | `grep -c UVM_ERROR <sim_log>` → `0` |
| G5 | No `UVM_FATAL` in sim log | `grep -c UVM_FATAL <sim_log>` → `0` |
| G6 | No compile errors | `grep -iE "error-|syntax error" <comp_log>` → no matches |
| G7 | No `UVM_ERROR` in compile log | `grep -c UVM_ERROR <comp_log>` → `0` (normally N/A at compile) |

### Gate script (bash / Git Bash)

Save as `sim/check_phase1_gate.sh`:

```bash
#!/usr/bin/env bash
# Usage: ./check_phase1_gate.sh [comp_log] [sim_log]
set -euo pipefail

COMP_LOG="${1:-dut_comp.log}"
SIM_LOG="${2:-phase1_tb_top_test_seed_0_sim.log}"
PHASE_MARK="PHASE 1 : testbench top"

fail() { echo "GATE FAIL: $1"; exit 1; }
pass() { echo "GATE PASS: $1"; }

[[ -f "$COMP_LOG" ]] || fail "compile log not found: $COMP_LOG"
[[ -f "$SIM_LOG"   ]] || fail "sim log not found: $SIM_LOG"

grep -q "$PHASE_MARK" "$SIM_LOG" \
  || fail "phase marker not found in $SIM_LOG (expect UVM_INFO with '$PHASE_MARK')"

grep -q "UVM_ERROR" "$COMP_LOG" && fail "UVM_ERROR found in $COMP_LOG"
grep -q "UVM_ERROR" "$SIM_LOG"   && fail "UVM_ERROR found in $SIM_LOG"

grep -qiE "error-|syntax error" "$COMP_LOG" \
  && fail "VCS error keyword found in $COMP_LOG"

grep -q "UVM_FATAL" "$SIM_LOG" && fail "UVM_FATAL found in $SIM_LOG"

pass "Phase 1 review gate — $SIM_LOG"
```

### Gate script (PowerShell — Windows)

```powershell
$CompLog = "dut_comp.log"
$SimLog  = "phase1_tb_top_test_seed_0_sim.log"
$Mark    = "PHASE 1 : testbench top"

if (-not (Test-Path $CompLog)) { throw "Missing $CompLog" }
if (-not (Test-Path $SimLog))  { throw "Missing $SimLog" }

$sim = Get-Content $SimLog -Raw
if ($sim -notmatch [regex]::Escape($Mark)) { throw "Phase marker not found" }
if ($sim -match "UVM_ERROR")  { throw "UVM_ERROR in sim log" }
if ($sim -match "UVM_FATAL")  { throw "UVM_FATAL in sim log" }

$comp = Get-Content $CompLog -Raw
if ($comp -match "(?i)error-|syntax error") { throw "Compile error in comp log" }
if ($comp -match "UVM_ERROR") { throw "UVM_ERROR in comp log" }

Write-Host "GATE PASS: Phase 1"
```

### Makefile gate target

```makefile
gate1:
	@./check_phase1_gate.sh $(COMP_LOG) $(SIM_LOG)

phase1: dv gate1
	@echo "Phase 1 complete."
```

**One-shot Phase 1 sign-off (user runs on VM):**

```bash
make dv TESTNAME=phase1_tb_top_test SEED=0
```

Then prompt the agent: **"check logfiles"** with paths to `dut_comp.log` and `phase1_tb_top_test_seed_0_sim.log`.

**Agent gate-only** (after user has run sim):

```bash
./check_phase1_gate.sh dut_comp.log phase1_tb_top_test_seed_0_sim.log
```

**If gate FAIL:** see **`FIX.md`** — Phase 1 (FIX-001, FIX-003, FIX-004, FIX-005, FIX-007, FIX-009, FIX-015).

---

## Phase 2 — UVM agents

### Goal

**Introduce `base_test` with factory topology debug, then integrate APB and LED agents layer-by-layer (transaction → driver/monitor/sequencer → agent → env) using existing `tb/` components where ready. A sanity test extending `base_test` proves each agent is factory-built, connected, and visible in `uvm_top.print_topology()`. No scoreboard, coverage, or SVA in this phase.**

**Prerequisite:** Phase 1 review gate PASS (`make dv TESTNAME=phase1_tb_top_test SEED=0`).

### Architecture layer map (build bottom → top)

Per ARCHITECTURE.md §3 and §4, integrate in this order. **Stop after each row, compile, run sanity test, check log, then prompt to proceed** with the next component name.

| Layer | ARCHITECTURE.md class | Student folder file | Status in repo |
|---|---|---|---|
| L0 | `base_test` | `tb/base_test.sv` | **Create** (factory + env hook) |
| L0 | `led_env` (agents only) | `tb/led_env.sv` or `tb/my_env.sv` | **Create / rename** — no SCB/COV yet |
| L1a | `apb_seq_item` | `tb/apb_agent/apb_transaction.sv` | **Ready** — rename optional |
| L1b | `led_seq_item` | `tb/led_agent/led_transaction.sv` | **Ready** — add `error_q` field per SPEC §4.1 |
| L2a | `apb_driver` | `tb/apb_agent/apb_driver.sv` | **Ready** — add build print; align `dut_vif` key |
| L2b | `apb_monitor` | `tb/apb_agent/apb_monitor.sv` | **Ready** — add build print |
| L2c | `apb_sequencer` | inside `apb_agent.sv` | **Ready** |
| L3a | `apb_agent` | `tb/apb_agent/apb_agent.sv` | **Ready** — add build print; `is_active` config |
| L2d | `led_driver` | `tb/led_agent/led_driver.sv` | **Ready** — fix `reset` vs `rst_n`; add build print |
| L2e | `led_monitor` | `tb/led_agent/led_monitor.sv` | **Ready** — add build print |
| L2f | `led_sequencer` | inside `led_agent.sv` | **Ready** |
| L3b | `led_agent` | `tb/led_agent/led_agent.sv` | **Ready** — add build print |
| L4 | `led_env` holds both agents | `tb/led_env.sv` | **Integrate** one agent at a time |
| — | `apb_if` | `tb/apb_agent/apb_if.sv` | **Ready** — map to SPEC `i_paddr`…`o_pslerr` in Phase 2 or Phase 3 |
| — | `led_if` | `tb/led_agent/led_if.sv` | **Extend** — add `error_q` input per SPEC §4.1 |
| — | Legacy `dp_agent/` | `tb/dp_agent/*` | **Do not integrate** — out of scope for LED MUX |

**Package wrappers:** `apb_agent_pkg.svh`, `led_agent_pkg.svh` — include in `dut.f` / `top_tb` imports.

### Step-by-step tasks

#### Block A — `base_test` and factory debug

| Step | Task | Output |
|---|---|---|
| 2.1 | Create **`base_test`** extending `uvm_test` | `tb/base_test.sv` |
| 2.1a | Add `UVM_PHASE_DRAIN_TIME = 1000ns` and `set_run_phase_drain_time(phase)` helper | `tb/base_test.sv` |
| 2.2 | In `build_phase`: create minimal **`led_env`** (empty or stub) via factory | `tb/led_env.sv` |
| 2.3 | Set `uvm_config_db` for `is_active = UVM_ACTIVE` on both agents (paths match env hierarchy) | `base_test.sv` |
| 2.4 | In **`end_of_elaboration_phase`**, add factory dump (required): | `base_test.sv` |

```systemverilog
function void end_of_elaboration_phase(uvm_phase phase);
  factory = uvm_factory::get();  // get the factory instance handle
  factory.print();
  uvm_top.print_topology();
endfunction
```

| 2.5 | Declare `uvm_factory factory;` member in `base_test` | `base_test.sv` |
| 2.6 | Add build print in `base_test`: | `base_test.sv` |

```systemverilog
`uvm_info(get_type_name(), "Build phase for base_test", UVM_LOW)
```

| 2.7 | Create **`phase2_agent_sanity_test`** extending **`base_test`** (not `phase1_tb_top_test`) | `tb/phase2_agent_sanity_test.sv` |
| 2.8 | Register test in **`test_lib.svh`**; keep `phase1_tb_top_test` for regression | `tb/test_lib.svh` |

#### Block B — Inventory check and per-agent integration loop

**For each agent (APB first, then LED), repeat steps 2.9–2.16. Prompt before starting the next component:**

> **Proceed with integration of `<component_name>`?** (y/n)

| Step | Task | Verification |
|---|---|---|
| 2.9 | **Inventory** — list files under `tb/apb_agent/` or `tb/led_agent/`; mark READY / NEEDS FIX / MISSING | Checklist table (§2.2) |
| 2.10 | **Align interface** — ensure `top_tb` `config_db` paths match agent get paths (`dut_vif` or `vif` — pick one, use everywhere) | No `uvm_config_db::get failed` in sim log |
| 2.11 | **Layer L1** — include transaction in package; add build print | Log: `Build phase for apb_transaction` |
| 2.12 | **Layer L2** — integrate driver, monitor; add build print in each `build_phase` | Log: `Build phase for apb_driver`, `apb_monitor` |
| 2.13 | **Layer L3** — integrate agent; sequencer created when `UVM_ACTIVE` | Log: `Build phase for apb_agent` |
| 2.14 | **Layer L4** — instantiate agent in `led_env`; add env build print | Log: `Build phase for led_env` |
| 2.15 | **User runs** sanity test after each agent (agent provides commands) | `make dv TESTNAME=phase2_agent_sanity_test SEED=0` |
| 2.16 | **Inspect topology** — confirm agent subtree in `factory.print()` / `print_topology()` output | See §2.3 agent checklist |

**APB agent integration order:** `apb_transaction` → `apb_driver` → `apb_monitor` → `apb_agent` → `led_env.apb_agt`

**LED agent integration order:** `led_transaction` → `led_driver` → `led_monitor` → `led_agent` → `led_env.led_agt`

#### Block C — Required `build_phase` print (every UVM component)

Add at the **start** of each component `build_phase`:

```systemverilog
`uvm_info(get_type_name(), "Build phase for <component_name>", UVM_LOW)
```

Replace `<component_name>` with the literal class role name:

| Component | Print string in log |
|---|---|
| `base_test` | `Build phase for base_test` |
| `led_env` | `Build phase for led_env` |
| `apb_transaction` | `Build phase for apb_transaction` |
| `apb_driver` | `Build phase for apb_driver` |
| `apb_monitor` | `Build phase for apb_monitor` |
| `apb_agent` | `Build phase for apb_agent` |
| `led_transaction` | `Build phase for led_transaction` |
| `led_driver` | `Build phase for led_driver` |
| `led_monitor` | `Build phase for led_monitor` |
| `led_agent` | `Build phase for led_agent` |

Gate script (§2.5) greps for each string expected at the current integration milestone.

#### Block D — Sanity test prints (phase verification)

`phase2_agent_sanity_test` extends `base_test`. In `run_phase`:

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  // Phase 1 carry-over (optional regression signal)
  `uvm_info("PHASE1_TB_TOP", "PHASE 1 : testbench top bring-up complete", UVM_LOW)
  // Per-agent instantiation checks (after each agent integrated)
  if (env.apb_agt == null)
    `uvm_error(get_type_name(), "apb_agent not instantiated in env")
  else
    `uvm_info(get_type_name(), "PHASE 2 : apb_agent instantiated", UVM_LOW)
  if (env.led_agt == null)
    `uvm_error(get_type_name(), "led_agent not instantiated in env")
  else
    `uvm_info(get_type_name(), "PHASE 2 : led_agent instantiated", UVM_LOW)
  // Final phase gate marker
  `uvm_info("PHASE2_AGENTS", "PHASE 2 : uvm agents integration complete", UVM_LOW)
  phase.drop_objection(this);
  set_run_phase_drain_time(phase);  // 1000ns — see §UVM test conventions
endtask
```

Integrate agents **one at a time**: comment out LED checks until APB milestone passes, then uncomment for full Phase 2 sign-off.

#### Block E — Agent instantiation checklist (topology)

After `uvm_top.print_topology()`, confirm **one by one**:

| # | Agent component | Expected topology path | Also check |
|---|---|---|---|
| A1 | `apb_agent` | `uvm_test_top.env.apb_agt` | `is_active == UVM_ACTIVE` |
| A2 | `apb_sequencer` | `...apb_agt.sequencer` | Present only if active |
| A3 | `apb_driver` | `...apb_agt.driver` | `seq_item_port` connected |
| A4 | `apb_monitor` | `...apb_agt.monitor` | Always present |
| A5 | `led_agent` | `uvm_test_top.env.led_agt` | `is_active == UVM_ACTIVE` |
| A6 | `led_sequencer` | `...led_agt.sequencer` | Present only if active |
| A7 | `led_driver` | `...led_agt.driver` | `seq_item_port` connected |
| A8 | `led_monitor` | `...led_agt.monitor` | Always present |

**config_db paths in `top_tb` (ARCHITECTURE §4):**

```systemverilog
uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt*", "dut_vif", apb_vif);
uvm_config_db#(virtual led_if)::set(null, "uvm_test_top.env.led_agt*", "dut_vif", led_vif);
```

Adjust key to `"vif"` if you standardise on ARCHITECTURE naming — driver/monitor `get()` must match.

| Step | Task | Output |
|---|---|---|
| 2.17 | Update **`dut.f`** — agent packages, `led_env.sv`, `base_test.sv`, `phase2_agent_sanity_test.sv` | `tb/dut.f` |
| 2.18 | Import packages in **`top_tb.sv`**: `import apb_agent_pkg::*; import led_agent_pkg::*;` | `tb/top_tb.sv` |
| 2.19 | **User runs** `make dv TESTNAME=phase2_agent_sanity_test SEED=0`; then prompts log check | Gate PASS / FAIL |
| 2.20 | **Prompt:** all agents integrated? Proceed to Phase 3 only if gate PASS | Sign-off row at bottom |

### Phase 2 marker (required in simulation log)

```text
PHASE 2 : uvm agents
```

Full string from sanity test: `PHASE 2 : uvm agents integration complete` (gate matches prefix `PHASE 2 : uvm agents`).

### Acceptance criteria (testable)

| ID | Criterion | Input | Expected output |
|---|---|---|---|
| AC-P2-01 | Compile succeeds | `make dv TESTNAME=phase2_agent_sanity_test SEED=0` | `dut_comp.log` exists; exit `0` |
| AC-P2-02 | No compile errors | `dut_comp.log` | No `Error-`, `Syntax error`, `*E` |
| AC-P2-03 | Simulation runs | `make dv TESTNAME=phase2_agent_sanity_test SEED=0` | `phase2_agent_sanity_test_seed_0_sim.log` exists |
| AC-P2-04 | Factory dump present | Sim log | `uvm_factory` / type list from `factory.print()` |
| AC-P2-05 | Topology dump present | Sim log | `UVM_INFO @ 0: uvm_test_top` tree from `print_topology()` |
| AC-P2-06 | Build prints — env | Sim log | `Build phase for base_test`, `Build phase for led_env` |
| AC-P2-07 | Build prints — APB stack | Sim log | `apb_transaction`, `apb_driver`, `apb_monitor`, `apb_agent` |
| AC-P2-08 | Build prints — LED stack | Sim log | `led_transaction`, `led_driver`, `led_monitor`, `led_agent` |
| AC-P2-09 | APB agent in topology | Sim log | Path contains `apb_agt` with driver, monitor, sequencer |
| AC-P2-10 | LED agent in topology | Sim log | Path contains `led_agt` with driver, monitor, sequencer |
| AC-P2-11 | Phase 2 marker | Sim log | `UVM_INFO` + `PHASE 2 : uvm agents` |
| AC-P2-12 | No UVM errors | Compile + sim logs | Zero `UVM_ERROR`, zero `UVM_FATAL` |
| AC-P2-13 | No simulator errors | Both logs | No `error-` / `syntax error` (case-insensitive in comp log) |
| AC-P2-14 | vif lookup OK | Sim log | No `uvm_config_db::get failed` for `dut_vif` / `vif` |

### Files created / modified (Phase 2 minimum)

```text
LED_MUX_CONTROLLER_stu/tb/
  base_test.sv                  # factory.print + print_topology; UVM_PHASE_DRAIN_TIME + drain helper
  led_env.sv                    # apb_agt + led_agt only (no scb/cov)
  phase2_agent_sanity_test.sv   # extends base_test; phase + agent checks
  test_lib.svh                  # include phase2 test
  dut.f                         # agent packages + new files
  apb_agent/*.sv                # build_phase prints; config_db key alignment
  led_agent/*.sv                # build_phase prints; led_if.error_q if added
  top_tb.sv                     # package imports; config_db agent paths
```

### Makefile — Phase 2 targets

Reuse §1.3 variables; override default test name:

```makefile
TESTNAME ?= phase2_agent_sanity_test

gate2:
	@./check_phase2_gate.sh $(COMP_LOG) $(SIM_LOG)

phase2: dv gate2
	@echo "Phase 2 complete."
```

**Sample commands:**

```bash
cd LED_MUX_CONTROLLER_stu && source proj1.setup && cd sim
make dv TESTNAME=phase2_agent_sanity_test SEED=0
```

### 2.5 Review gate — Phase 2

Same rules as Phase 1 (§1.4): logs must exist; phase marker found; **no `UVM_ERROR` or `errors` keyword** in compile and sim logs.

**Additional Phase 2 checks:**

| # | Check | Command / rule |
|---|---|---|
| G8 | Phase marker | `grep -q "PHASE 2 : uvm agents" <sim_log>` |
| G9 | Factory dump | `grep -q "uvm_factory" <sim_log>` or `Type Name` table from `factory.print()` |
| G10 | Topology | `grep -q "uvm_test_top" <sim_log>` after `print_topology` |
| G11 | Build prints (full sign-off) | `grep -c "Build phase for apb_agent" <sim_log>` ≥ 1 (same for `led_agent`) |
| G12 | Agent instances | `grep -q "apb_agt" <sim_log>` and `grep -q "led_agt" <sim_log>` |

**Gate script** — save as `sim/check_phase2_gate.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
COMP_LOG="${1:-dut_comp.log}"
SIM_LOG="${2:-phase2_agent_sanity_test_seed_0_sim.log}"
PHASE_MARK="PHASE 2 : uvm agents"

fail() { echo "GATE FAIL: $1"; exit 1; }

[[ -f "$COMP_LOG" ]] || fail "missing $COMP_LOG"
[[ -f "$SIM_LOG"   ]] || fail "missing $SIM_LOG"

grep -q "$PHASE_MARK" "$SIM_LOG" || fail "phase marker not found"
grep -q "UVM_ERROR" "$COMP_LOG" && fail "UVM_ERROR in compile log"
grep -q "UVM_ERROR" "$SIM_LOG"   && fail "UVM_ERROR in sim log"
grep -qiE "error-|syntax error" "$COMP_LOG" && fail "compile errors in $COMP_LOG"
grep -q "UVM_FATAL" "$SIM_LOG" && fail "UVM_FATAL in sim log"
grep -q "Build phase for apb_agent" "$SIM_LOG" || fail "missing APB build print"
grep -q "Build phase for led_agent" "$SIM_LOG" || fail "missing LED build print"

echo "GATE PASS: Phase 2 — $SIM_LOG"
```

**PowerShell (Windows):**

```powershell
$CompLog = "dut_comp.log"
$SimLog  = "phase2_agent_sanity_test_seed_0_sim.log"
$Mark    = "PHASE 2 : uvm agents"
# Same checks as §1.4 plus:
# $sim -match "Build phase for apb_agent"
# $sim -match "Build phase for led_agent"
```

**If gate FAIL:** see **`FIX.md`** — Phase 2 (FIX-003, FIX-006, FIX-008, FIX-010).

### Integration prompt template (repeat per component)

Use this checklist when pausing between components:

```text
--- Phase 2 integration checkpoint ---
Component : <apb_driver | apb_monitor | apb_agent | led_driver | ...>
Compile   : PASS / FAIL  (dut_comp.log)
Sim run   : PASS / FAIL  (<test>_seed_0_sim.log)
Build print: grep "Build phase for <component>" → found / missing
Topology  : <component> visible in print_topology → yes / no
Errors    : UVM_ERROR count = 0 required

Proceed with next component: <next_name>? [y/n]
```

### Known gaps in student `tb/` (fix during integration)

| Item | Current state | Action for Phase 2 |
|---|---|---|
| `led_if` | Missing `error_q` | Add 20-bit `error_q` per SPEC §4.1 |
| `apb_if` signal names | `paddr` vs `i_paddr` | Align modport / DUT hookup in `top_tb` |
| `led_driver` | Uses `dut_vif.reset` | Match `led_if` (`rst_n` or `reset`) |
| Transaction naming | `apb_transaction` | Keep or alias to `apb_seq_item` |
| `dp_agent/` | Legacy SDRAM stubs | Exclude from `dut.f` |
| `my_env.sv` | Referenced in old logs | Replace with `led_env.sv` per ARCHITECTURE |

---

## Phase 3 — P0 tests, scoreboard, and SVA (feature loop)

### Goal

**Implement all 11 essential (P0) tests from `LED_MUX_CONTROLLER_testplan.xlsx` / TESTPLAN.md §1.1 and §2, one feature set at a time.** If the scoreboard does not exist yet, create **at least one** P0 test and its sequence(s) **before** integrating the scoreboard shell. For each test: create or extend sequences and the UVM test, extend the **single** `led_scoreboard` when SCB is needed (do not add extra scoreboards), add SVA to **one** bind file when required, run `make dv TESTNAME=<test> SEED=0`, and pass the per-test gate before moving on. Phase 3 ends when E01–E11 all pass individually; Phase 4 runs `./regress_p0.sh`.

**Prerequisite:** Phase 2 review gate PASS (`make dv TESTNAME=phase2_agent_sanity_test SEED=0`).

**Source of truth:** Excel rows with **Priority = P0** (11 tests). Generate with:

```bash
python scripts/generate_testplan.py --owner "slpoh" --tier p0
```

### Phase 3 workflow (repeat per feature / test)

```text
┌─────────────────────────────────────────────────────────────┐
│ 0. (First time only) If no scoreboard yet:                  │
│    a. Pick first P0 test (§3.2, typically E07)              │
│    b. Create sequence(s) + *_test; register test_lib       │
│    c. make dv TESTNAME=<first_p0_test> SEED=0 → gate PASS   │
│    d. Then create scoreboard shell + env connect (§3.1)     │
├─────────────────────────────────────────────────────────────┤
│ 1. Pick next P0 test from build order (§3.2)                │
│ 2. Create / extend sequences (§3.3)                         │
│ 3. Extend led_scoreboard only if test needs SCB (§3.4)      │
│ 4. Add SVA to led_mux_sva.sv + bind if test needs SVA (§3.5)│
│ 5. Create or update *_test; register test_lib               │
│ 6. make dv TESTNAME=<test> SEED=0                            │
│ 7. Per-test gate: no errors + factory lists new test (§3.8)│
│ 8. Prompt: proceed to next P0 test?                         │
└─────────────────────────────────────────────────────────────┘
```

**Rule:** Finish **one** P0 test (compile, sim, gate PASS) before starting the next. Do not batch multiple tests without a green gate in between.

**Scoreboard entry rule:** If `led_scoreboard` / `led_tb_pkg` have **never** been created, build **at least one** P0 test and its required sequence(s) **first**, run compile + sim, and get a clean log **before** adding the scoreboard shell or wiring it into `led_env`. This proves agents and sequences work before checker integration.

**Incremental run rule (mandatory):** After **each** new or modified **component**, **sequence**, or **test** is added, the agent must **stop** and print the `make dv` command for the user. The user runs on the VM and prompts `check logfiles` before the agent adds the next item.

| Step type | Verify with | Example |
|---|---|---|
| First P0 sequence + test (no scoreboard yet) | Compile + sim on new test | `make dv TESTNAME=led_reset_values_test SEED=0` |
| New scoreboard / env hook (first time only) | Compile + first P0 test or phase2 sanity | `make dv TESTNAME=led_reset_values_test SEED=0` after env wired |
| New sequence (scoreboard exists) | Compile + test that uses it | After `apb_read_seq`: run test that calls it |
| New P0 test | Full per-test gate (§3.8) | `make dv TESTNAME=apb_reset_defaults_test SEED=0` |

**Agent prompt template (after every addition):**

```text
--- Phase 3 checkpoint ---
Added      : <component | sequence | test name>
Files      : <paths>
Run on VM  : make dv TESTNAME=<test> SEED=0
Expected   : compile clean; sim log for <test>
Next step  : (do not proceed until user prompts check logfiles)
```

---

### 3.1 Shared infrastructure (build once, before full P0 loop)

Complete these steps **once** at the start of Phase 3. All P0 tests reuse them.

**Order when scoreboard does not exist yet:** Steps **3.1.1–3.1.5** (first test + sequence) come **before** steps **3.1.6–3.1.10** (scoreboard). If the scoreboard is already in the repo and wired in `led_env`, skip 3.1.1–3.1.5 and extend SCB logic per test in the loop below.

#### 3.1.A First P0 test + sequence (before scoreboard — if never created)

| Step | Task | File(s) |
|---|---|---|
| 3.1.1 | Pick **first** P0 test from §3.2 (recommended: **E07** `led_reset_values_test`) | `LED_MUX_CONTROLLER_testplan.xlsx` |
| 3.1.2 | Create **sequence(s)** required by that test (e.g. `led_reset_seq` for E07) | `tb/sequences/*.sv` |
| 3.1.3 | Create **`<testname>_test.sv`** extending `base_test`; register in **`test_lib.svh`** | `tb/*_test.sv`, `tb/test_lib.svh` |
| 3.1.4 | **User runs** first P0 test — **no scoreboard required yet** | `make dv TESTNAME=led_reset_values_test SEED=0` |
| 3.1.5 | **User prompts** log check — compile clean, factory lists new test, `UVM_ERROR=0` | sim log |

Do **not** create `led_scoreboard`, `led_tb_pkg`, or env scoreboard connections until 3.1.4–3.1.5 pass.

#### 3.1.B Scoreboard shell + env connect (after first test compiles — if never created)

| Step | Task | File(s) |
|---|---|---|
| 3.1.6 | Create **`led_scoreboard.sv`** with `uvm_analysis_imp_decl` macros at **top of file**, before `class led_scoreboard` | `tb/led_scoreboard.sv` |
| 3.1.7 | Create **`led_tb_pkg`** — imports + `uvm_macros.svh` + `` `include "led_scoreboard.sv" `` | `tb/led_tb_pkg.svh` |
| 3.1.8 | Add **`led_tb_pkg.svh`** to **`dut.f`**; `import led_tb_pkg::*` in **`top_tb.sv`** | `tb/dut.f`, `tb/top_tb.sv` |
| 3.1.9 | Extend **`led_env`**: add `led_scoreboard scb`; **`connect_phase`** monitor → imp ports | `tb/led_env.sv` |
| 3.1.10 | **User runs** first P0 test again with scoreboard wired | `make dv TESTNAME=led_reset_values_test SEED=0` |

#### 3.1.C Remaining shared infra (incremental per test)

| Step | Task | File(s) |
|---|---|---|
| 3.1.11 | Add more **shared sequences** as later P0 tests need them (TESTPLAN §0.1) | `tb/sequences/*.sv` |
| 3.1.12 | Create **one** SVA module + **one** `bind` in `top_tb` when first test needs SVA | `tb/sva/led_mux_sva.sv`, `tb/top_tb.sv` |
| 3.1.13 | Add build prints in new components | `led_scoreboard`, `led_mux_sva` |
| 3.1.14 | **`test_lib.svh`** — **do not** `include` `led_scoreboard.sv` (comes from package) | `tb/test_lib.svh` |

#### Scoreboard creation — step by step (UVM 1.2 / VCS)

**Why a package:** VCS cannot compile `uvm_analysis_imp_decl` + parameterized imp ports when the scoreboard is included only from `test_lib.svh` inside the `top_tb` module. Compile the scoreboard through **`led_tb_pkg`** via **`dut.f`**, and `import led_tb_pkg::*` in `top_tb.sv`.

**Macro placement:** Put `` `uvm_analysis_imp_decl(_apb) `` and `` `uvm_analysis_imp_decl(_led) `` at the **top of `led_scoreboard.sv`**, immediately **before** `class led_scoreboard`. The package only `` `include ``s the file — do not duplicate the macros in `led_tb_pkg.svh`.

**Naming rule (UVM `uvm_analysis_imp_decl`):** The macro argument is the **suffix** `SFX` (include the leading `_`). UVM defines class type **`uvm_analysis_imp` + `SFX`** and requires write function **`write` + `SFX`** (without the leading `_` in the function name).

| Macro call | Imp port type (in scoreboard) | Write callback (in scoreboard) |
|---|---|---|
| `` `uvm_analysis_imp_decl(_apb) `` | `uvm_analysis_imp_apb #(apb_transaction, led_scoreboard)` | `function void write_apb(apb_transaction tr);` |
| `` `uvm_analysis_imp_decl(_led) `` | `uvm_analysis_imp_led #(led_transaction, led_scoreboard)` | `function void write_led(led_transaction tr);` |

**Do not** use `apb_analysis_imp_apb` or `led_analysis_imp_led` — those types are **not** created by the macro.

**Step A — `tb/led_scoreboard.sv` (macros first, then class):**

```systemverilog
// Macros BEFORE class — order matters
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_led)

class led_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(led_scoreboard)

  uvm_analysis_imp_apb #(apb_transaction, led_scoreboard) apb_imp;
  uvm_analysis_imp_led #(led_transaction, led_scoreboard) led_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for led_scoreboard", UVM_LOW)
    apb_imp = new("apb_imp", this);
    led_imp = new("led_imp", this);
  endfunction

  function void write_apb(apb_transaction tr);
    // SCB-1..3, 7..9 — add per P0 test
  endfunction

  function void write_led(led_transaction tr);
    // SCB-4..6, 8 — add per P0 test
  endfunction
endclass
```

**Step B — `tb/led_tb_pkg.svh` (include scoreboard only):**

```systemverilog
package led_tb_pkg;
  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import led_agent_pkg::*;

  `include "uvm_macros.svh"
  `include "led_scoreboard.sv"
endpackage
```

**Step C — filelist and imports:**

- `dut.f`: add `../tb/led_tb_pkg.svh` **after** agent packages, **before** `top_tb.sv`
- `top_tb.sv`: `import led_tb_pkg::*;`
- `test_lib.svh`: **no** `include "led_scoreboard.sv"`

**Step D — `tb/led_env.sv` connect:**

```systemverilog
led_scoreboard scb;

function void build_phase(uvm_phase phase);
  // ... agents ...
  scb = led_scoreboard::type_id::create("scb", this);
endfunction

function void connect_phase(uvm_phase phase);
  apb_agt.monitor.analysis_port.connect(scb.apb_imp);
  led_agt.monitor.analysis_port.connect(scb.led_imp);
endfunction
```

**Step E — verify (user on VM):**

```bash
cd LED_MUX_CONTROLLER_stu/sim
make clean
make dv TESTNAME=phase2_agent_sanity_test SEED=0
```

Sim log must show: `Build phase for led_scoreboard`, `led_scoreboard` under `env` in topology, `led_scoreboard` in `factory.print()`, `UVM_ERROR : 0`. Use the **first P0 test** (e.g. `led_reset_values_test`) — not only `phase2_agent_sanity_test` — once it exists.

#### Virtual sequencer (create once — shared by all P0 vseqs)

**`tb/led_virtual_sequencer.sv`** — holds handles to both agent sequencers. Create before `led_env` (include order in `test_lib.svh`).

```systemverilog
class led_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(led_virtual_sequencer)
  uvm_sequencer #(apb_transaction) apb_seqr;
  uvm_sequencer #(led_transaction) led_seqr;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass
```

**`led_env.sv`** — instantiate `v_seqr` in `build_phase`; wire to agent sequencers in `connect_phase`:

```systemverilog
led_virtual_sequencer v_seqr;
// build_phase:
v_seqr = led_virtual_sequencer::type_id::create("v_seqr", this);
// connect_phase:
v_seqr.apb_seqr = apb_agt.sequencer;
v_seqr.led_seqr = led_agt.sequencer;
```

**Virtual sequence pattern** — every vseq declares `p_sequencer` and starts sub-sequences on it directly:

```systemverilog
class my_vseq extends uvm_sequence;
  `uvm_object_utils(my_vseq)
  `uvm_declare_p_sequencer(led_virtual_sequencer)
  task body();
    led_reset_seq rs = led_reset_seq::type_id::create("rs");
    rs.start(p_sequencer.led_seqr);      // LED physical sequencer
    some_apb_seq.start(p_sequencer.apb_seqr); // APB physical sequencer
  endtask
endclass
```

**Test pattern** — tests reference only `env.v_seqr`; no physical sequencer handles in test:

```systemverilog
vseq = my_vseq::type_id::create("vseq");
vseq.start(env.v_seqr);
```

#### Shared sequences to create (TESTPLAN §0.1)

| Sequence | File | Used by P0 tests |
|---|---|---|
| `led_virtual_sequencer` | `tb/led_virtual_sequencer.sv` | All P0 vseqs |
| `led_reset_seq` | `tb/sequences/led_reset_seq.sv` | All vseqs (via `p_sequencer.led_seqr`) |
| `led_reset_vseq` | `tb/sequences/led_reset_vseq.sv` | E07 |
| `apb_write_seq` | `tb/sequences/apb_write_seq.sv` | E03, E06, E08, E10 |
| `apb_read_seq` | `tb/sequences/apb_read_seq.sv` | E02, E03, E04, E06 |
| `apb_wr_rd_seq` | `tb/sequences/apb_wr_rd_seq.sv` | E03, E04 |
| `apb_invalid_addr_seq` | `tb/sequences/apb_invalid_addr_seq.sv` | E05 |
| `apb_done_poll_seq` | `tb/sequences/apb_done_poll_seq.sv` | E01, E08, E09, E11 |
| `led_error_seq` | `tb/sequences/led_error_seq.sv` | E01, E08, E09, E10, E11 |
| `led_mux_virtual_seq` | `tb/sequences/led_mux_virtual_seq.sv` | E01, E08, E09, E10, E11 |

Package include: `tb/sequences/led_sequences_pkg.svh` (or add to agent packages).

#### Single scoreboard — simplify, extend in place

Use **one** `led_scoreboard` in **`led_tb_pkg`** for all P0 tests. Add checks incrementally when a test needs them (TESTPLAN §0.2 SCB-1..9):

| SCB ID | Add when first needed by | Logic (simplified) |
|---|---|---|
| SCB-1 | E03 | Mirror `LED_enable` on APB write/read `0x4000` |
| SCB-2 | E02 | Track `Done` on read `0x4004` |
| SCB-3 | E04 | Scratch pad mirror `0x4008` |
| SCB-4..6 | E08 | Golden bin→BCD + 7-seg compare after `Done==1` |
| SCB-7 | E10 | Skip compare when `LED_enable==0` |
| SCB-8 | E08 | Skip `seg_out` compare when `Done==0` |
| SCB-9 | E09 | Expected = `error_q % 1_000_000` |

```systemverilog
// tb/led_scoreboard.sv — add in build_phase:
`uvm_info(get_type_name(), "Build phase for led_scoreboard", UVM_LOW)
```

**Do not** create `apb_scoreboard`, `led_check`, or per-test scoreboards — extend `led_scoreboard` only.

#### Single SVA file + bind (Context7 / IEEE 1800 pattern)

Put **all** concurrent assertions and cover properties in **`tb/sva/led_mux_sva.sv`**. Bind **once** to the DUT in `top_tb.sv`. Add a second file only if you must `bind` to a different hierarchy (e.g. APB slave submodule); otherwise add properties to the same module.

**SVA module skeleton** (Surelog / IEEE concurrent assertion style):

```systemverilog
// tb/sva/led_mux_sva.sv
module led_mux_sva (
  input logic        clk,
  input logic        rst_n,
  input logic [5:0]  sel_out,
  input logic [7:0]  seg_out,
  input logic [19:0] error_q,
  // APB — map to apb_if signals wired from DUT
  input logic        psel,
  input logic        penable,
  input logic        pready,
  input logic        pslerr
);

  // --- add properties incrementally per P0 test (§3.6) ---

  // Example: assert_sel_out_reset_value (E02, E07)
  property p_sel_out_reset;
    @(posedge clk) disable iff (!rst_n)
      $rose(rst_n) |-> ##1 (sel_out == 6'h3E);
  endproperty
  assert_sel_out_reset_value: assert property (p_sel_out_reset);

  // Example: cover property
  cover_sel_out_digit_position: cover property (
    @(posedge clk) disable iff (!rst_n) $onehot0(~sel_out)
  );

endmodule
```

**Bind in `top_tb.sv`** (one bind target — DUT instance):

```systemverilog
bind dut led_mux_sva i_led_mux_sva (
  .clk     (dp_mux_clk),
  .rst_n   (rst_n),
  .sel_out (sel_out),
  .seg_out (seg_out),
  .error_q (led_if_inst.error_q),  // after led_if extended
  .psel    (apb_if_inst.psel),
  .penable (apb_if_inst.penable),
  .pready  (apb_if_inst.pready),
  .pslerr  (apb_if_inst.pslverr)
);
```

Use `default_clocking` / `disable iff (!rst_n)` on each property. Name every property per TESTPLAN §0.3 (`assert_*`, `cover_*`, `check_*`).

**Incremental SVA rule:** Add properties when the **first** P0 test that lists them in the Excel **Assertions/Cover property** column is implemented. Do not add unused properties ahead of the test that needs them.

---

### 3.2 P0 build order (one test at a time)

Implement in this order so each test builds on sequences/checkers from prior steps:

| Order | ID | Test name | Block | New infra this step |
|---|---|---|---|---|
| 0a | E07 | `led_reset_values_test` | LED | **First:** `led_reset_seq` + test only — **no scoreboard**; gate PASS |
| 0b | — | *(shared)* | Infra | **Then:** `led_scoreboard` shell, `led_tb_pkg`, env `connect_phase`; re-run E07 |
| 0c | E07 | `led_reset_values_test` | LED | SVA: `assert_sel_out_reset_value`, `assert_seg_out_reset_value` |
| 1 | E02 | `apb_reset_defaults_test` | APB | `apb_read_seq`; SCB-1,2,3 |
| 2 | E06 | `apb_pready_no_wait_test` | APB | SVA: `assert_apb_setup_phase`, `assert_apb_access_phase`, `assert_apb_pready_complete` |
| 3 | E03 | `apb_led_enable_write_read_test` | APB | SCB-1 |
| 4 | E04 | `apb_scratchpad_wr_rd_test` | APB | SCB-3 |
| 5 | E05 | `apb_invalid_addr_test` | APB | SVA: `assert_apb_pslerr_invalid_addr`; MON `pslerr` |
| 6 | E08 | `led_decimal_42_test` | LED | `led_mux_virtual_seq`; SCB-4,5,6,8; SVA one-hot, bit7, `check_60_80_cycle` |
| 7 | E09 | `led_overflow_modulo_test` | LED | SCB-9 |
| 8 | E10 | `led_disable_blocks_update_test` | LED | SCB-7 |
| 9 | E11 | `led_all_digits_0_to_9_test` | LED | SCB-5; `cover_seg_out_decimal_digit` |
| 10 | E01 | `smoke_test` | Integration | Full SCB + all §0.3 properties exercised |

---

### 3.3 Per-test implementation checklist

For **each** row in §3.2, complete these steps:

| Step | Action |
|---|---|
| 3.3.1 | Open matching row in `LED_MUX_CONTROLLER_testplan.xlsx` (Priority **P0**) |
| 3.3.2 | Create **`<testname>_test.sv`** extending **`base_test`** (not `phase2_agent_sanity_test`) |
| 3.3.3 | In `build_phase`: `factory.set_type_override` only if needed; else default factory create |
| 3.3.4 | In `run_phase`: `raise_objection` → start virtual/child sequences from Excel **Test Steps** → `drop_objection` → `set_run_phase_drain_time(phase)` (1000ns) |
| 3.3.5 | Add phase marker: `` `uvm_info("PHASE3_P0", "PHASE 3 : P0 <testname> complete", UVM_LOW) `` |
| 3.3.6 | Register in **`test_lib.svh`** |
| 3.3.7 | **User runs:** `make dv TESTNAME=<testname> SEED=0` |
| 3.3.8 | **User prompts** log check; agent runs per-test gate (§3.8) |
| 3.3.9 | **Prompt:** `Proceed with P0 test <next_testname>? [y/n]` |

#### P0 test detail (from TESTPLAN §2 + Excel)

| ID | Test | Sequences | Scoreboard | SVA to add this step |
|---|---|---|---|---|
| E07 | `led_reset_values_test` | `led_reset_seq` | — | `assert_sel_out_reset_value`, `assert_seg_out_reset_value` |
| E02 | `apb_reset_defaults_test` | `led_reset_seq` → `apb_read_seq`×3 | SCB-1,2,3 | *(reuse reset SVA)* |
| E06 | `apb_pready_no_wait_test` | `apb_write_seq`, `apb_read_seq` | — | `assert_apb_setup_phase`, `assert_apb_access_phase`, `assert_apb_pready_complete` |
| E03 | `apb_led_enable_write_read_test` | `apb_wr_rd_seq` | SCB-1 | — |
| E04 | `apb_scratchpad_wr_rd_test` | `apb_wr_rd_seq` (`0x4008`, `32'hDEAD_BEEF`) | SCB-3 | — |
| E05 | `apb_invalid_addr_test` | `apb_invalid_addr_seq` | — | `assert_apb_pslerr_invalid_addr` |
| E08 | `led_decimal_42_test` | `led_mux_virtual_seq` (`error_q=42`) | SCB-4,5,6,8 | `assert_sel_out_onehot_active_low`, `assert_seg_out_bit7_always_one`, `check_60_80_cycle` |
| E09 | `led_overflow_modulo_test` | `led_mux_virtual_seq` (`error_q=1_000_001`) | SCB-9 | *(reuse one-hot, bit7)* |
| E10 | `led_disable_blocks_update_test` | `led_mux_virtual_seq` (enable=0) | SCB-7 | — |
| E11 | `led_all_digits_0_to_9_test` | `led_mux_virtual_seq` loop d=0..9 | SCB-5 | `cover_seg_out_decimal_digit` |
| E01 | `smoke_test` | Reset → enable → `error_q=42` → poll Done | all SCB | all §0.3 properties active |

#### Example test class (pattern for every P0 test)

Tests start **one** virtual sequence on `env.v_seqr`. No physical sequencer handles in the test.

```systemverilog
class led_decimal_42_test extends base_test;
  `uvm_component_utils(led_decimal_42_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    led_mux_virtual_seq vseq;
    phase.raise_objection(this);
    vseq = led_mux_virtual_seq::type_id::create("vseq");
    vseq.error_q = 20'd42;
    vseq.start(env.v_seqr);   // always start on virtual sequencer
    `uvm_info("PHASE3_P0", "PHASE 3 : P0 led_decimal_42_test complete", UVM_LOW)
    phase.drop_objection(this);
    set_run_phase_drain_time(phase);
  endtask
endclass
```

---

### 3.4 Scoreboard integration (extend one file)

When a P0 test needs checking:

1. Open **`tb/led_scoreboard.sv`** only.
2. Add `write_apb` / `write_led` logic for the SCB IDs listed in §3.3 table.
3. Reuse `ref_model()` / `bcd_to_seg()` inline — no separate reference model file unless logic exceeds ~50 lines.
4. Add build print if not already present.
5. Recompile and re-run **only that test** before proceeding.

**Compare gating** (TESTPLAN §6.3 — implement once in scoreboard):

| Condition | Action |
|---|---|
| `Done == 0` | Do not compare `seg_out` (SCB-8) |
| `LED_enable == 0` | Do not expect `seg_out` update (SCB-7) |
| `Done == 1` && `LED_enable == 1` | Run golden compare (SCB-4..6, 9) |

---

### 3.5 SVA integration (one file, bind to DUT)

| Step | Action |
|---|---|
| 3.5.1 | Add property to **`tb/sva/led_mux_sva.sv`** using names from TESTPLAN §0.3 |
| 3.5.2 | If signals are on DUT ports → extend existing `bind dut` port list |
| 3.5.3 | If signals are only on interface → tap from `apb_if` / `led_if` in `top_tb` bind |
| 3.5.4 | New bind target (e.g. `dut.u_apb_slave`) → **new file** `tb/sva/apb_slave_sva.sv` + second bind (exception only) |
| 3.5.5 | Compile with `ASSERT=1` in `proj1.setup` / makefile |
| 3.5.6 | On failure: property name appears in `dut_sva.rpt` / sim log — fix RTL or test stimulus |

#### SVA add order (matches P0 build)

| When implementing | Add to `led_mux_sva.sv` |
|---|---|
| E07, E02 | `assert_sel_out_reset_value`, `assert_seg_out_reset_value` |
| E06 | `assert_apb_setup_phase`, `assert_apb_access_phase`, `assert_apb_pready_complete` |
| E05 | `assert_apb_pslerr_invalid_addr` |
| E08 | `assert_sel_out_onehot_active_low`, `assert_seg_out_bit7_always_one`, `check_60_80_cycle` |
| E11 | `cover_seg_out_decimal_digit` |
| E01 | `cover_sel_out_digit_position`, `check_hold_1002_cycle` (+ confirm all prior properties) |

---

### 3.6 Files created / modified (Phase 3)

```text
LED_MUX_CONTROLLER_stu/tb/
  led_virtual_sequencer.sv      # v_seqr: apb_seqr + led_seqr handles (BEFORE led_env in test_lib)
  led_tb_pkg.svh                # package — includes led_scoreboard.sv
  led_env.sv                    # scb + v_seqr; connect_phase wires v_seqr to agent sequencers
  led_scoreboard.sv             # uvm_analysis_imp_decl macros + scoreboard class
  sva/
    led_mux_sva.sv              # all assert/cover/check properties
  sequences/
    led_reset_seq.sv            # physical LED sequence (called from vseqs via p_sequencer.led_seqr)
    led_reset_vseq.sv           # virtual sequence — wraps led_reset_seq (E07)
    apb_write_seq.sv
    apb_read_seq.sv
    apb_wr_rd_seq.sv
    apb_invalid_addr_seq.sv
    apb_done_poll_seq.sv
    led_error_seq.sv
    led_mux_virtual_seq.sv
    led_sequences_pkg.svh
  tests/                        # or flat under tb/
    led_reset_values_test.sv
    apb_reset_defaults_test.sv
    ...                         # 11 P0 tests total
    smoke_test.sv
  test_lib.svh                  # include order: led_virtual_sequencer → led_env → sequences → tests
  top_tb.sv                     # bind dut led_mux_sva
  dut.f
```

---

### 3.7 Makefile — Phase 3 targets

```makefile
# Per-test run
run_p0:
	$(MAKE) run TESTNAME=$(TESTNAME) SEED=$(SEED)

# All 11 P0 tests (Phase 3 exit criteria)
P0_TESTS = led_reset_values_test apb_reset_defaults_test apb_pready_no_wait_test \
           apb_led_enable_write_read_test apb_scratchpad_wr_rd_test \
           apb_invalid_addr_test led_decimal_42_test led_overflow_modulo_test \
           led_disable_blocks_update_test led_all_digits_0_to_9_test smoke_test

regress_p0:
	@for t in $(P0_TESTS); do \
	  $(MAKE) run TESTNAME=$$t SEED=0 || exit 1; \
	  ./check_phase3_gate.sh dut_comp.log $${t}_seed_0_sim.log $$t; \
	done
	@echo "P0 regression PASS"

phase3: regress_p0
	@echo "Phase 3 complete — all P0 tests pass."
```

**Sample commands:**

```bash
# Single P0 test
make dv TESTNAME=led_decimal_42_test SEED=0

# Full P0 batch (Phase 4)
./regress_p0.sh
```

---

### 3.8 Per-test review gate

**Pass criteria for each P0 test** (same pattern as Phase 1 / 2):

| # | Check | Rule |
|---|---|---|
| G1 | Compile log | `dut_comp.log` exists; no `error-` / `syntax error` |
| G2 | Sim log | `<testname>_seed_0_sim.log` exists |
| G3 | Phase marker | `grep -q "PHASE 3 : P0 <testname>" <sim_log>` |
| G4 | No UVM errors | Zero `UVM_ERROR`, zero `UVM_FATAL` in compile + sim logs |
| G5 | Factory lists new test | `factory.print()` output contains `<testname>` or test type name |
| G6 | Topology | `print_topology()` shows test as `uvm_test_top` instance type |
| G7 | Scoreboard quiet | No unexpected `uvm_error` from `led_scoreboard` |
| G8 | SVA quiet | No assertion failures for properties this test enables (unless negative test) |

**Gate script** — `sim/check_phase3_gate.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
COMP_LOG="${1:-dut_comp.log}"
SIM_LOG="${2:-smoke_test_seed_0_sim.log}"
TESTNAME="${3:-smoke_test}"
PHASE_MARK="PHASE 3 : P0 ${TESTNAME}"

fail() { echo "GATE FAIL [$TESTNAME]: $1"; exit 1; }

[[ -f "$COMP_LOG" ]] || fail "missing compile log"
[[ -f "$SIM_LOG"   ]] || fail "missing sim log"

grep -q "$PHASE_MARK" "$SIM_LOG" || fail "phase marker not found"
grep -q "UVM_ERROR" "$COMP_LOG" && fail "UVM_ERROR in compile log"
grep -q "UVM_ERROR" "$SIM_LOG"   && fail "UVM_ERROR in sim log"
grep -qiE "error-|syntax error" "$COMP_LOG" && fail "compile errors"
grep -q "UVM_FATAL" "$SIM_LOG" && fail "UVM_FATAL in sim log"

# Factory registered the test type (from base_test end_of_elaboration_phase)
grep -qE "${TESTNAME}|uvm_test_top" "$SIM_LOG" || fail "test not visible in topology/factory dump"

echo "GATE PASS: P0 $TESTNAME"
```

**`base_test` factory dump** (required — inherited from Phase 2): after each new test is added, `factory.print()` in the sim log must show the new test class registered via `uvm_component_utils` / `test_lib.svh`.

**If gate FAIL:** see **`FIX.md`** — Phase 3 (FIX-006, FIX-011, FIX-012).

---

### 3.9 Acceptance criteria (Phase 3 complete)

| ID | Criterion | Input | Expected |
|---|---|---|---|
| AC-P3-01 | All P0 sequences compile | `make dv TESTNAME=<any_p0_test> SEED=0` | No errors in `dut_comp.log` |
| AC-P3-02 | Single scoreboard | Code review | Only `led_scoreboard.sv`; no duplicate checkers |
| AC-P3-03 | Single SVA bind file | Code review | `led_mux_sva.sv` + one `bind dut` (unless §3.5.4 exception) |
| AC-P3-04 | Each P0 test passes individually | 11× `check_phase3_gate.sh` | All PASS |
| AC-P3-05 | `regress_p0` | `./regress_p0.sh` | Exit code 0; 11 sim logs clean |
| AC-P3-06 | Excel traceability | `LED_MUX_CONTROLLER_testplan.xlsx` | Every P0 row has matching `*_test.sv` |
| AC-P3-07 | TESTPLAN §7 closed | Traceability matrix | SCB/SVA columns satisfied per test |
| AC-P3-08 | `smoke_test` | `make dv TESTNAME=smoke_test SEED=0` | All checkers exercised; no errors |

---

### 3.10 Integration prompt template (per P0 test)

```text
--- Phase 3 P0 checkpoint ---
Test      : <testname>  (Excel Priority: P0)
Sequences : <list>
SCB added : SCB-<n> / none
SVA added : <property names> / none
Compile   : PASS / FAIL
Sim       : PASS / FAIL
Factory   : <testname> visible in factory.print → yes / no
Errors    : UVM_ERROR=0 required

Proceed with P0 test <next_testname>? [y/n]
```

---

## Phase 4 — P0 regression sign-off

### Goal

Confirm all **11 P0 tests** pass after Phase 3. Each test was already gated individually; Phase 4 runs the full suite in one batch.

### Farm vs local regression

**Ask before Phase 4:**

```text
Do you have a farm/grid regression flow (LSF, SGE, SLURM, internal CI)?
  • Yes → document farm submit command in this section
  • No  → use sim/regress_p0.sh (created for this project)
```

| Option | Command |
|---|---|
| **Local batch (default)** | `cd sim && ./regress_p0.sh` |
| **Farm (if available)** | Submit `regress_p0.sh` via your site command, e.g. `bsub -q normal ./regress_p0.sh` |

### Local batch script — `sim/regress_p0.sh`

Runs every P0 test with `make dv TESTNAME=<test> SEED=0` (TESTPLAN §1.1):

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../proj1.setup

P0_TESTS=(
  led_reset_values_test
  apb_reset_defaults_test
  apb_pready_no_wait_test
  apb_led_enable_write_read_test
  apb_scratchpad_wr_rd_test
  apb_invalid_addr_test
  led_decimal_42_test
  led_overflow_modulo_test
  led_disable_blocks_update_test
  led_all_digits_0_to_9_test
  smoke_test
)

for t in "${P0_TESTS[@]}"; do
  echo "=== P0 regression: $t ==="
  make dv TESTNAME="$t" SEED=0
done
echo "P0 batch complete — prompt agent: check logfiles for regress_p0"
```

**User runs on VM:**

```bash
cd LED_MUX_CONTROLLER_stu/sim
chmod +x regress_p0.sh
./regress_p0.sh
```

### Review gate — Phase 4

| # | Check |
|---|---|
| G1 | 11 sim logs exist: `<testname>_seed_0_sim.log` |
| G2 | Each log: zero `UVM_ERROR`, zero `UVM_FATAL` |
| G3 | Each log: `PHASE 3 : P0 <testname>` present |
| G4 | Final `dut_comp.log`: no compile errors |

Then prompt agent: **`check logfiles for regress_p0`**

**If gate FAIL:** see **`FIX.md`** — Phase 4 (FIX-006, FIX-013); see also Phase 3 entries for failing tests.

---

## Phase 5 — Coverage closure (goal only)

**Goal:** P1 tests + `random_regression_test`; TESTPLAN Excel annotated with PASS and coverage %.

**Gate:** Functional covergroups ≥ target; code coverage report merged.

**If gate FAIL:** see **`FIX.md`** — tooling (FIX-014) and Phase 3 simulation errors.

---

## Quick reference — sample commands (user runs on VM)

**Copy these on the Linux VM. The agent does not run them and waits until you prompt `check logfiles`.**

```bash
# --- Setup (every session) ---
cd LED_MUX_CONTROLLER_stu && source proj1.setup && cd sim

# --- Phase 1 ---
make clean
make dv TESTNAME=phase1_tb_top_test SEED=0
# → prompt agent: check logfiles

# --- Phase 2 ---
make dv TESTNAME=phase2_agent_sanity_test SEED=0
# → prompt agent: check logfiles for phase 2

# --- Phase 3 (one P0 test) ---
make dv TESTNAME=led_decimal_42_test SEED=0
# → prompt agent: check logfiles for led_decimal_42_test

# --- Phase 4 (full P0 regression) ---
./regress_p0.sh
# → prompt agent: check logfiles for regress_p0

# --- Logs the agent will read ---
#   sim/dut_comp.log
#   sim/<TESTNAME>_seed_0_sim.log
```

---

## Traceability

| PLAN.md | ARCHITECTURE.md | TESTPLAN.md |
|---|---|---|
| Phase 1 `top_tb` | §4 Static top (`tb_top.sv`) | — (infra) |
| Phase 2 agents | §1 agents, §3 class diagram, §4 env/agents | P0 prep |
| Phase 2 `base_test` | §4 Test layer — factory, config_db | — |
| Phase 3 P0 loop | §0.1–0.3, §1.1, §2, §7 | `LED_MUX_CONTROLLER_testplan.xlsx` P0 rows |
| Phase 3 `led_scoreboard` | §0.2, §3 class diagram SCB | SCB-1..9 |
| Phase 3 `led_mux_sva` | §0.3, §4 Static top bind | All assert/cover/check names |
| Phase 4 `regress_p0` | — | §9 regression P0 |
| Phase 5 | — | §1.2 P1 + §9 regression |
| Any phase | **FIX.md** | Known errors / resolutions |

---

*Update gate status in this file after each phase: date, owner, log paths, PASS/FAIL.*
