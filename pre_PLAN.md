# Verification pre_PLAN — Skeleton Template

**Purpose:** Reusable verification build plan for UVM projects. Copy this file to **`PLAN.md`** per project and fill every `{{placeholder}}`.

**Do not execute simulation on Windows** — the agent generates files and make commands only; the user runs VCS on the Linux VM and prompts log review.

**If compile or simulation fails:** check **`FIX.md`** for known errors and fixes before changing code at random.

---

## How to instantiate for a new project

1. Copy `pre_PLAN.md` → `PLAN.md` in the project root.
2. Replace all `{{placeholders}}` with project-specific names (see §Placeholder glossary).
3. Link to your `SPEC.md`, `ARCHITECTURE.md`, and `TESTPLAN.md` (or Excel).
4. Customize phase count, gate tests, and build order for the DUT.
5. Keep this `pre_PLAN.md` unchanged as the master skeleton.
6. Create **`FIX.md`** from the template in this repo (or copy and extend per project).

**Example (this repo):** `PLAN.md` — LED MUX Controller; **`FIX.md`** — known errors.

---

## Document header (fill in PLAN.md)

```markdown
# Verification PLAN — {{PROJECT_NAME}}

**Template source:** pre_PLAN.md
**References:** {{SPEC_DOC}} · {{ARCH_DOC}} · {{TESTPLAN_DOC}} · **FIX.md**
**Tool:** {{SIMULATOR}} + {{UVM_VERSION}}
**Project tree:** `{{PROJECT_ROOT}}/` (RTL `{{RTL_DIR}}/`, TB `{{TB_DIR}}/`, sim `{{SIM_DIR}}/`)
```

---

## Agent / user workflow (mandatory — copy verbatim)

**{{SIMULATOR}} runs on the course Linux VM only — not on Windows. The agent never runs compile or simulation.**

### How to run (for users)

1. **Agent** creates or updates source files and prints **exact shell commands**.
2. **Agent stops** — wait for you to run on the VM.
3. **You** log in to the Linux machine, run commands, confirm logs under `{{PROJECT_ROOT}}/{{SIM_DIR}}/`.
4. **You** prompt the agent, e.g. `check logfiles` or `check logfiles for phase 2`.
5. **Agent** reads `{{MODULE}}_comp.log` and `<TESTNAME>_seed_<SEED>_sim.log`, applies the phase gate, reports **PASS** or **FAIL**.

Do not proceed to the next phase until the current gate is **PASS**.

### One-time setup (each VM session)

```bash
cd /path/to/{{PROJECT_ROOT}}
source {{SETUP_SCRIPT}}
cd {{SIM_DIR}}
chmod +x run_sim.csh check_phase*_gate.sh 2>/dev/null
```

### Agent / user roles

| Step | Who | Action |
|---|---|---|
| 1 | **Agent** | Create or update RTL/TB/UVM/SVA files |
| 2 | **Agent** | Print **make commands**; **stop** |
| 3 | **User** | Run on Linux VM; collect logs |
| 4 | **User** | Prompt: *check logfiles* |
| 5 | **Agent** | Gate checklist → PASS/FAIL; if FAIL, search **FIX.md** with user |

| Log pattern | Example |
|---|---|
| Compile | `{{SIM_DIR}}/{{MODULE}}_comp.log` |
| Simulation | `{{SIM_DIR}}/<TESTNAME>_seed_<SEED>_sim.log` |
| Fixes | **`FIX.md`** (repo root) |

**Gate criteria (every phase):** phase marker in sim log; zero `UVM_ERROR` / `UVM_FATAL`; no compile `error-` / `syntax error`.

**On gate FAIL:** grep logs for the error text → open **`FIX.md`** quick lookup table → apply fix → re-run `make {{RUN_TARGET}} TESTNAME=<test> SEED=0` → prompt `check logfiles` again.

### UVM test conventions (all phases)

Every UVM test **`run_phase`** must set **{{UVM_PHASE_DRAIN_TIME}}** phase drain time after `drop_objection` so monitors, drivers, and scoreboard TLM can flush before the run phase ends.

| Phase | Pattern |
|---|---|
| 1 | `phase.drop_objection(this);` then `phase.phase_done.set_drain_time(this, {{UVM_PHASE_DRAIN_TIME}});` in standalone gate test |
| 2–5 | Tests extending `{{BASE_TEST}}`: `phase.drop_objection(this);` then `set_run_phase_drain_time(phase);` |

**`{{BASE_TEST}}` helper** (define once in `tb/{{BASE_TEST}}.sv`):

```systemverilog
localparam time UVM_PHASE_DRAIN_TIME = {{UVM_PHASE_DRAIN_TIME}};

function void set_run_phase_drain_time(uvm_phase phase);
  phase.phase_done.set_drain_time(this, UVM_PHASE_DRAIN_TIME);
endfunction
```

Do **not** call `super` in UVM phase methods (project convention).

---

## Phase overview (template)

| Phase | Name | Single goal | Gate test |
|---|---|---|---|
| **1** | Testbench top | Static `{{TB_TOP}}` — DUT, interfaces, clk/rst, `config_db`, `run_test()` | `{{PHASE1_TEST}}` |
| **2** | UVM agents | `{{BASE_TEST}}` + agents integrated layer-by-layer | `{{PHASE2_TEST}}` |
| **3** | P0 tests + checkers | First test + sequence, then scoreboard if new; P0 loop from testplan | Per-test → `regress_p0` |
| **4** | P0 regression sign-off | All P0 tests pass in one regression | `regress_p0` |
| **5** | Coverage closure | P1 tests + coverage annotation | Testplan Excel |

> Detail Phases 1–3 in `PLAN.md`. Phases 4–5 use the same gate pattern.

---

## Phase 1 — Testbench top (template)

### Goal

**{{PHASE1_GOAL_ONE_SENTENCE}}**

### Step-by-step tasks

| Step | Task | Output |
|---|---|---|
| 1.1 | Source `{{SETUP_SCRIPT}}` (`ROOT`, `MODULE`, `UVM_HOME`, …) | Env set |
| 1.2 | Create / update virtual interfaces per spec | `{{TB_DIR}}/.../*_if.sv` |
| 1.3 | Instantiate DUT in `{{TB_TOP}}` | `{{TB_DIR}}/{{TB_TOP}}.sv` |
| 1.4 | Clock + reset generators | `{{TB_TOP}}.sv` |
| 1.5 | `uvm_config_db` for virtual interfaces | `{{TB_TOP}}.sv` |
| 1.6 | `run_test()` (no hard-coded test name) | `{{TB_TOP}}.sv` |
| 1.7 | Create `{{PHASE1_TEST}}` with phase marker | `{{TB_DIR}}/{{PHASE1_TEST}}.sv` |
| 1.8 | Add test to **`test_lib.svh`**; **`include` in `{{TB_TOP}}.sv` after `import uvm_pkg::*`** — **do not** list `test_lib.svh` or `*_test.sv` in **`{{FILELIST}}`** | `test_lib.svh`, `{{TB_TOP}}.sv` |
| 1.9 | **Agent prompts user** to confirm the run command matches the project makefile (see §Run command) | User verifies `TESTNAME`, `SEED`, `{{RUN_TARGET}}` |
| 1.10 | **User runs** confirmed command on VM | `{{MODULE}}_comp.log`, `<TESTNAME>_seed_<SEED>_sim.log` |
| 1.11 | **User prompts** log check; agent runs gate (§1.4) | PASS / FAIL |

### Run command (confirm before every phase)

**Agent must print the command and ask the user to confirm it matches `{{SIM_DIR}}/makefile` before the user runs.**

Standard pattern for this workflow:

```bash
make {{RUN_TARGET}} TESTNAME={{PHASE1_TEST}} SEED=0
```

| Variable | Typical value | Notes |
|---|---|---|
| `{{RUN_TARGET}}` | `dv` | Course wrapper: compile + elaborate + sim via `run_sim.csh` |
| `TESTNAME` | phase / gate test name | Must match UVM test class registered in `test_lib.svh` |
| `SEED` | `0` (fixed) or random | Default `0` for gate tests |

**Agent prompt (copy):**

```text
Please confirm the run command for Phase 1:
  cd {{PROJECT_ROOT}} && source {{SETUP_SCRIPT}} && cd {{SIM_DIR}}
  make {{RUN_TARGET}} TESTNAME={{PHASE1_TEST}} SEED=0
Expected logs: {{MODULE}}_comp.log, {{PHASE1_TEST}}_seed_0_sim.log
Reply after run with: check logfiles
```

### Phase 1 marker (sim log)

```text
{{PHASE1_MARKER}}
```

```systemverilog
`uvm_info("{{PHASE1_ID}}", "{{PHASE1_MARKER}} bring-up complete", UVM_LOW)
```

**`run_phase` drain time (required):** after `drop_objection`, call `phase.phase_done.set_drain_time(this, {{UVM_PHASE_DRAIN_TIME}});`

### `{{TB_TOP}}.sv` include order (required)

```systemverilog
`include "uvm_macros.svh"

module {{TB_TOP}};
  import uvm_pkg::*;
  `include "test_lib.svh"   // after import; NOT in {{FILELIST}}

  // interfaces, DUT, clk, rst, config_db, run_test()
endmodule
```

### Acceptance criteria (template)

| ID | Criterion | Expected |
|---|---|---|
| AC-P1-01 | Compile succeeds | `{{MODULE}}_comp.log`; exit 0 |
| AC-P1-02 | No compile errors | No `Error-`, `syntax error`; no duplicate test compile via filelist |
| AC-P1-03 | `{{SIMV}}` created | Binary exists |
| AC-P1-04 | Simulation runs | `<TESTNAME>_seed_<SEED>_sim.log`; exit 0 |
| AC-P1-05 | Phase marker | `UVM_INFO` + `{{PHASE1_MARKER}}` |
| AC-P1-06 | No UVM errors | Zero `UVM_ERROR`, `UVM_FATAL` |

### Makefile targets (template)

Primary run uses **`make {{RUN_TARGET}}`** (not bare `vcs` / `simv` unless makefile has no wrapper):

```makefile
TESTNAME ?= {{PHASE1_TEST}}
SEED     ?= 0

# Course / project wrapper — compile + elab + run
{{RUN_TARGET}}: run_dv

run_dv:
	${ROOT}/{{SIM_DIR}}/run_sim.csh dv ${MODULE} ${TESTNAME} ${SEED}

gate1:
	@./check_phase1_gate.sh $(COMP_LOG) $(SIM_LOG)
```

### User commands — Phase 1

```bash
cd {{PROJECT_ROOT}} && source {{SETUP_SCRIPT}} && cd {{SIM_DIR}}
make clean
make {{RUN_TARGET}} TESTNAME={{PHASE1_TEST}} SEED=0
# → prompt agent: check logfiles
```

### Review gate — Phase 1 (template)

| # | Check |
|---|---|
| G1 | Compile log exists |
| G2 | Sim log exists |
| G3 | `grep -q "{{PHASE1_MARKER}}" <sim_log>` |
| G4–G5 | No `UVM_ERROR` / `UVM_FATAL` in sim |
| G6 | No compile `error-` / `syntax error` |

**Gate script:** `{{SIM_DIR}}/check_phase1_gate.sh` — parameterize `PHASE_MARK="{{PHASE1_MARKER}}"`.

**If gate FAIL:** see **`FIX.md`** — Phase 1 (FIX-001, FIX-003, FIX-004, FIX-005, FIX-007, FIX-015).

---

## Phase 2 — UVM agents (template)

### Goal

**{{PHASE2_GOAL_ONE_SENTENCE}}**

### Prerequisites

- Phase 1 gate PASS
- `{{BASE_TEST}}` with `factory.print()` and `uvm_top.print_topology()` in `end_of_elaboration_phase`

### Layer integration order (customize per ARCHITECTURE)

| Layer | Component | Action |
|---|---|---|
| L0 | `{{BASE_TEST}}`, `{{ENV}}` | Create; factory debug |
| L1 | `*_seq_item` / `*_transaction` | Per agent |
| L2 | driver, monitor, sequencer | Build prints in each `build_phase` |
| L3 | `*_agent` | One agent at a time |
| L4 | `{{ENV}}` | Instantiate agent; connect in `connect_phase` |
| L5 | `{{VIRTUAL_SEQR}}` | Create in `{{ENV}}` build; wire handles to agent sequencers in `connect_phase` |

**Virtual sequencer pattern (Phase 3+):** All virtual sequences use `uvm_declare_p_sequencer({{VIRTUAL_SEQR}})` and access agent sequencers via `p_sequencer.apb_seqr` / `p_sequencer.led_seqr`. Tests start vseqs on `env.v_seqr` only — no physical sequencer handles in tests.

**Build print (every component):**

```systemverilog
`uvm_info(get_type_name(), "Build phase for <component_name>", UVM_LOW)
```

**Sanity test:** `{{PHASE2_TEST}}` extends `{{BASE_TEST}}`. End `run_phase` with `set_run_phase_drain_time(phase)` ({{UVM_PHASE_DRAIN_TIME}}).

### Phase 2 marker

```text
{{PHASE2_MARKER}}
```

### User commands — Phase 2

```bash
make {{RUN_TARGET}} TESTNAME={{PHASE2_TEST}} SEED=0
# → prompt agent: check logfiles for phase 2
```

### Review gate — Phase 2 (add to Phase 1 checks)

| # | Check |
|---|---|
| G8 | Phase marker `{{PHASE2_MARKER}}` |
| G9 | `factory.print()` in log |
| G10 | `print_topology()` shows agents |
| G11 | `Build phase for <agent>` strings present |

**If gate FAIL:** see **`FIX.md`** — Phase 2 (FIX-003, FIX-006, FIX-008, FIX-010).

---

## Phase 3 — P0 tests, scoreboard, SVA (template)

### Goal

**Implement all P0 tests from `{{TESTPLAN_XLS}}` / TESTPLAN one feature at a time.** If the scoreboard has never been created, build at least one P0 test and its sequence(s) before scoreboard integration.

### Shared infrastructure — Phase 3 entry order

**Scoreboard entry rule:** If `{{SCOREBOARD}}` / `{{TB_PKG}}` have **never** been created, build **at least one** P0 test and its required sequence(s) **first**. Run compile + sim and get a clean log **before** adding the scoreboard shell or wiring it into `{{ENV}}`.

#### 3.1.A First P0 test + sequence (before scoreboard — if never created)

| Step | Task | File(s) |
|---|---|---|
| 3.1.1 | Pick **first** P0 test from build order (recommended: **E07** `led_reset_values_test`) | `{{TESTPLAN_XLS}}` |
| 3.1.2 | Create **sequence(s)** for that test (e.g. `led_reset_seq`) | `tb/sequences/*.sv` |
| 3.1.3 | Create **`<testname>_test.sv`**; register in **`test_lib.svh`** | `tb/*_test.sv`, `test_lib.svh` |
| 3.1.4 | **User runs** — **no scoreboard yet** | `make {{RUN_TARGET}} TESTNAME=<first_p0_test> SEED=0` |
| 3.1.5 | **User prompts** log check — compile clean, factory lists test, `UVM_ERROR=0` | sim log |

Do **not** create `{{SCOREBOARD}}`, `{{TB_PKG}}`, or env scoreboard connections until 3.1.4–3.1.5 pass.

#### 3.1.B Scoreboard shell + env connect (after first test — if never created)

VCS requires the scoreboard compiled through a **package**. Place `uvm_analysis_imp_decl` macros at the **top of the scoreboard file**, before the class.

| Step | Task | File(s) |
|---|---|---|
| 3.1.6 | Create **`{{SCOREBOARD}}.sv`** — macros at top, then class | `tb/{{SCOREBOARD}}.sv` |
| 3.1.7 | Create **`{{TB_PKG}}`** — imports + `uvm_macros.svh` + `` `include "{{SCOREBOARD}}.sv" `` | `tb/{{TB_PKG}}.svh` |
| 3.1.8 | Add package to **`{{FILELIST}}`**; `import {{TB_PKG}}::*` in **`{{TB_TOP}}.sv`** | `{{FILELIST}}`, `{{TB_TOP}}.sv` |
| 3.1.9 | Extend **`{{ENV}}`**: `scb` + **`connect_phase`** monitor → imp ports | `tb/{{ENV}}.sv` |
| 3.1.10 | **User runs** first P0 test again with scoreboard wired | `make {{RUN_TARGET}} TESTNAME=<first_p0_test> SEED=0` |

If scoreboard already exists and is wired, skip 3.1.1–3.1.10 and extend SCB logic per test in the workflow loop below.

#### `uvm_analysis_imp_decl` naming rule (UVM 1.2)

Macro argument = suffix `SFX` (use leading `_`, e.g. `_apb`). UVM creates imp type **`uvm_analysis_imp` + `SFX`** and write function **`write` + suffix without `_`**.

**Macro placement:** At the **top of `{{SCOREBOARD}}.sv`**, before `class {{SCOREBOARD}}`. Do **not** put macros in `{{TB_PKG}}.svh` — the package only includes the scoreboard file.

| Macro | Imp port type in scoreboard | Write callback |
|---|---|---|
| `` `uvm_analysis_imp_decl(_apb) `` | `uvm_analysis_imp_apb #(apb_transaction, {{SCOREBOARD}})` | `function void write_apb(apb_transaction tr);` |
| `` `uvm_analysis_imp_decl(_led) `` | `uvm_analysis_imp_led #(led_transaction, {{SCOREBOARD}})` | `function void write_led(led_transaction tr);` |

**Wrong:** `apb_analysis_imp_apb`, `led_analysis_imp_led` — not defined by the macro.

**Scoreboard skeleton (`tb/{{SCOREBOARD}}.sv`) — macros first:**

```systemverilog
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_led)

class {{SCOREBOARD}} extends uvm_scoreboard;
  `uvm_component_utils({{SCOREBOARD}})

  uvm_analysis_imp_apb #(apb_transaction, {{SCOREBOARD}}) apb_imp;
  uvm_analysis_imp_led #(led_transaction, {{SCOREBOARD}}) led_imp;

  function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Build phase for {{SCOREBOARD}}", UVM_LOW)
    apb_imp = new("apb_imp", this);
    led_imp = new("led_imp", this);
  endfunction

  function void write_apb(apb_transaction tr); endfunction
  function void write_led(led_transaction tr); endfunction
endclass
```

**Package skeleton (`tb/{{TB_PKG}}.svh`) — include only:**

```systemverilog
package {{TB_PKG}};
  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import led_agent_pkg::*;

  `include "uvm_macros.svh"
  `include "{{SCOREBOARD}}.sv"
endpackage
```

**`{{FILELIST}}`:** add `../tb/{{TB_PKG}}.svh` after agent packages, before `{{TB_TOP}}.sv`.  
**`test_lib.svh`:** do **not** `include "{{SCOREBOARD}}.sv"` — types come from package import in `{{TB_TOP}}.sv`.

### Workflow loop (per P0 test)

**First-time Phase 3 (no scoreboard yet):**

1. Create first P0 test + sequence(s) (§3.1.A) → user runs → gate PASS
2. Create scoreboard shell + env connect (§3.1.B) → user re-runs first P0 test → gate PASS
3. Continue loop below for remaining P0 tests

**Per-test loop (after scoreboard exists):**

1. Pick next P0 test from build order table in `PLAN.md`
2. Create or extend sequences
3. Extend **one** `{{SCOREBOARD}}` only if test needs SCB (no extra scoreboards)
4. Add SVA to **one** `{{SVA_MODULE}}.sv` + `bind` when test needs it
5. Create or update test; register in `test_lib.svh`
6. **User runs:** `make {{RUN_TARGET}} TESTNAME=<test> SEED=0`
7. **User prompts** log check
8. Proceed only on PASS

Each P0 test `run_phase` must call `set_run_phase_drain_time(phase)` after `drop_objection` ({{UVM_PHASE_DRAIN_TIME}}).

**Incremental run rule (mandatory):** After each new **component**, **sequence**, or **test**, the agent stops and prints `make {{RUN_TARGET}} TESTNAME=<test> SEED=0`. User runs on VM → prompts `check logfiles` → agent continues.

| Step type | Verify with |
|---|---|
| First P0 sequence + test (no scoreboard) | `make {{RUN_TARGET}} TESTNAME=<first_p0_test> SEED=0` |
| Scoreboard + env (first time) | Re-run `<first_p0_test>` after wiring |
| Later sequence / test | Test that uses the new item |

### Phase 3 marker (per test)

```text
PHASE 3 : P0 <testname>
```

### User commands — Phase 3

```bash
make {{RUN_TARGET}} TESTNAME={{EXAMPLE_P0_TEST}} SEED=0
# → prompt agent: check logfiles for <test>
```

### Review gate — Phase 3 (per test)

Same as Phase 1/2 plus: factory lists new test; scoreboard/SVA quiet unless negative test.

**If gate FAIL:** see **`FIX.md`** — Phase 3 (FIX-006, FIX-011, FIX-012).

---

## Phase 4 — P0 regression sign-off (template)

### Goal

**All P0 tests pass in a single regression after Phase 3 is complete.**

### Step 1 — Ask about farm / grid regression

**Agent must prompt the user before creating regression scripts:**

```text
Do you have a farm or grid regression flow for this project?
  (e.g. LSF bsub, SGE qsub, SLURM sbatch, internal CI)
  [ ] Yes — provide farm command template or script path
  [ ] No  — I will create a local batch script with all make dv commands
```

| User answer | Agent action |
|---|---|
| **Farm available** | Document `{{FARM_SUBMIT_CMD}}` and test list in `PLAN.md`; user submits jobs on farm |
| **No farm** | Create `{{SIM_DIR}}/{{REGRESS_BATCH}}` — shell script that runs every P0 test |

### Step 2 — Local batch script (when no farm)

Create `{{REGRESS_BATCH}}` with one line per P0 test:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ../{{SETUP_SCRIPT}}
# Repeat for each P0 test from TESTPLAN:
make {{RUN_TARGET}} TESTNAME={{P0_TEST_1}} SEED=0
make {{RUN_TARGET}} TESTNAME={{P0_TEST_2}} SEED=0
# ...
echo "P0 batch regression complete — prompt agent: check logfiles for regress_p0"
```

| Step | Task |
|---|---|
| 4.1 | List all P0 test names from `{{TESTPLAN_DOC}}` / Excel |
| 4.2 | Generate `{{REGRESS_BATCH}}` with `make {{RUN_TARGET}} TESTNAME=<each> SEED=0` |
| 4.3 | `chmod +x {{REGRESS_BATCH}}` |
| 4.4 | **User runs** `./{{REGRESS_BATCH}}` on VM |
| 4.5 | **User prompts** agent to check **all** `*_seed_0_sim.log` + last `{{MODULE}}_comp.log` |

### Review gate — Phase 4

| # | Check |
|---|---|
| G1 | Every P0 test has a sim log |
| G2 | Each log: zero `UVM_ERROR`, zero `UVM_FATAL` |
| G3 | Each log: `PHASE 3 : P0 <testname>` present (from Phase 3) |
| G4 | No compile errors in final `{{MODULE}}_comp.log` |

**User command (local batch):**

```bash
cd {{PROJECT_ROOT}}/{{SIM_DIR}}
./{{REGRESS_BATCH}}
# → prompt agent: check logfiles for regress_p0
```

**If gate FAIL:** see **`FIX.md`** — Phase 4 (FIX-006, FIX-013); also per-test Phase 3 entries.

---

## Phase 5 — Coverage closure (template)

**Goal:** P1 tests + `{{RANDOM_REGRESS_TEST}}`; annotate testplan Excel with PASS and coverage %.

**If gate FAIL:** see **`FIX.md`** — tooling (FIX-014) and Phase 3 sim errors.

---

## Quick reference (template — user runs on VM)

```bash
cd {{PROJECT_ROOT}} && source {{SETUP_SCRIPT}} && cd {{SIM_DIR}}

make {{RUN_TARGET}} TESTNAME={{PHASE1_TEST}} SEED=0
# → check logfiles

make {{RUN_TARGET}} TESTNAME={{PHASE2_TEST}} SEED=0
# → check logfiles for phase 2

make {{RUN_TARGET}} TESTNAME={{EXAMPLE_P0_TEST}} SEED=0
# → check logfiles for <test>

./{{REGRESS_BATCH}}
# → check logfiles for regress_p0
```

---

## Placeholder glossary

| Placeholder | Example (LED MUX) | Description |
|---|---|---|
| `{{PROJECT_NAME}}` | LED MUX Controller | Display name |
| `{{PROJECT_ROOT}}` | `LED_MUX_CONTROLLER_stu` | Repo / course folder |
| `{{SPEC_DOC}}` | SPEC.md | Requirements |
| `{{ARCH_DOC}}` | ARCHITECTURE.md | TB architecture |
| `{{TESTPLAN_DOC}}` | TESTPLAN.md | Test plan markdown |
| `{{TESTPLAN_XLS}}` | LED_MUX_CONTROLLER_testplan.xlsx | Excel export |
| `{{SIMULATOR}}` | Synopsys VCS | Simulator |
| `{{UVM_VERSION}}` | UVM 1.2 | UVM release |
| `{{SETUP_SCRIPT}}` | proj1.setup | `source` env script |
| `{{RTL_DIR}}` | src | RTL path |
| `{{TB_DIR}}` | tb | Testbench path |
| `{{SIM_DIR}}` | sim | Makefile / logs |
| `{{MODULE}}` | dut | DUT module name |
| `{{TB_TOP}}` | top_tb | TB top module |
| `{{FILELIST}}` | dut.f | VCS `-file` list |
| `{{SIMV}}` | dut_simv | Sim executable |
| `{{BASE_TEST}}` | base_test | Root UVM test class |
| `{{ENV}}` | led_env | UVM environment |
| `{{TB_PKG}}` | led_tb_pkg | Package — includes `{{SCOREBOARD}}.sv` |
| `{{SCOREBOARD}}` | led_scoreboard | Scoreboard file — macros at top, then class |
| `{{VIRTUAL_SEQR}}` | led_virtual_sequencer | Virtual sequencer — `apb_seqr` + `led_seqr` handles; wired in `{{ENV}}` connect_phase |
| `{{SVA_MODULE}}` | led_mux_sva | Bound assertion module |
| `{{PHASE1_TEST}}` | phase1_tb_top_test | Phase 1 gate test |
| `{{PHASE2_TEST}}` | phase2_agent_sanity_test | Phase 2 gate test |
| `{{PHASE1_MARKER}}` | PHASE 1 : testbench top | Log substring |
| `{{PHASE2_MARKER}}` | PHASE 2 : uvm agents | Log substring |
| `{{PHASE1_ID}}` | PHASE1_TB_TOP | `uvm_info` id |
| `{{EXAMPLE_P0_TEST}}` | led_decimal_42_test | Sample P0 test |
| `{{RUN_TARGET}}` | dv | Makefile target (`make dv`) |
| `{{UVM_PHASE_DRAIN_TIME}}` | 1000ns | Run-phase drain after `drop_objection` (all tests) |
| `{{REGRESS_BATCH}}` | regress_p0.sh | Local P0 batch script (Phase 4) |
| `{{FARM_SUBMIT_CMD}}` | *(optional)* | Farm submit, e.g. `bsub regress_p0.sh` |
| `FIX.md` | FIX.md | Known errors and fixes (all phases) |
| `{{RANDOM_REGRESS_TEST}}` | random_regression_test | P1 closure test |

---

## Traceability block (template)

| PLAN.md section | ARCHITECTURE | TESTPLAN |
|---|---|---|
| Phase 1 `{{TB_TOP}}` | Static top | — |
| Phase 2 agents | Agents / env | P0 prep |
| Phase 3 P0 | SCB / SVA | P0 rows |
| Phase 4 | — | Regression |
| Phase 5 | Coverage | P1 |
| Any phase | **FIX.md** | Error lookup |

---

*Keep `pre_PLAN.md` generic. Record phase sign-off (date, owner, PASS/FAIL) in project `PLAN.md` only.*
