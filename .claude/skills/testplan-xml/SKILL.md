---
name: testplan-xml
description: Generate the LED_MUX_CONTROLLER Hierarchical Verification Plan (HVP) and run Synopsys urg -xmlplan to produce an annotated testplan.xml with live test pass/fail and coverage scores. Use when the user asks to build/update/regenerate the testplan.xml, HVP plan, or verification plan XML report for this project.
---

# testplan-xml

Generates `LED_MUX_CONTROLLER_stu/sim/testplan.xml`: a Synopsys Verification
Planner (HVP) annotated report showing, per feature/test, pass/fail status
and code/functional coverage — sourced live from this project's existing
`TESTPLAN.md` test list and the VCS coverage database (`dut_simv.vdb`).

Reference: `v_planner.pdf` at the repo root (Synopsys Verification Planner
User Guide) documents the HVP language and the `plan.xml` DTD this skill
produces.

## What it does

1. Reuses the test list (feature / subfeature / test / priority / goal)
   already defined in `scripts/generate_testplan.py` (`ROWS`) — the same
   data that generates `LED_MUX_CONTROLLER_testplan.xlsx`. Do not duplicate
   that table; if the test list changes, update `ROWS` there first.
2. For each test, reads `LED_MUX_CONTROLLER_stu/sim/<test>_seed_*_sim.log`
   and derives pass/fail using the exact CLAUDE.md Rule 6 gate: phase
   marker present, `UVM_ERROR : 0`, `UVM_FATAL : 0` in the summary block.
   Tests with no log yet are left out of the userdata (reported as
   no-score / not-yet-run, not silently marked pass).
3. Writes `led_mux_controller_testplan.hvp` (HVP plan source) and
   `test_results.hvpdata` (HVP userdata for the `test` metric — there's no
   Execution Manager in this flow, so results are supplied externally).
4. Runs `urg -dir dut_simv.vdb -plan <plan>.hvp -userdata test_results.hvpdata
   -xmlplan -report urgReport` (after sourcing `proj1.setup`) to produce
   `urgReport/plan.xml`, and copies it to `sim/testplan.xml`.

## Usage

```
python3.11 .claude/skills/testplan-xml/generate_hvp_testplan.py [--owner NAME] [--tier p0|p1|p2|all] [--line-goal N]
```

Use `python3.11` or `python3.12` explicitly — the default `python3` on
this box is 3.6.8, too old for `scripts/generate_testplan.py`'s type
hints. `openpyxl` is not required for this script (it's stubbed out).

- `--owner`: sets the `owner` attribute on every feature (default: none).
- `--tier`: filter to P0/P1/P2 tests only, or `all` (default: `all`, 38 tests).
- `--line-goal`: line coverage goal percent for the coverage feature (default: 80).

Requires `LED_MUX_CONTROLLER_stu/sim/dut_simv.vdb` to already exist (i.e.
at least one test must have been run via `make dv TESTNAME=<test> SEED=0`
per CLAUDE.md Rule 5). The script sources `proj1.setup` itself — do not
run it from a shell that has already sourced it from within `sim/`.

## Re-running

Safe to re-run any time after new tests are added to `sim/` or `ROWS` is
updated — it regenerates the `.hvp`/userdata files from scratch and
re-invokes `urg`. It does not run simulations itself.

## Notes

- Coverage is reported for the whole DUT (`tree: top_tb.dut_inst`) under a
  single `Code_and_Functional_Coverage` feature, not per sub-block — the
  project's submodule instances (`apb_slave_inst`, `i_led_mux_sva`, `m3`,
  `m4`, `watchdog_inst`) don't map 1:1 onto the ROWS feature groups, so
  splitting it out was more likely to mislead than help. If per-block
  coverage is wanted later, add more `measure SnpsAvg ...; source =
  "tree: top_tb.dut_inst.<instance>";` blocks inside the relevant feature.
- Per CLAUDE.md Rule 4, this skill never edits scoreboard/SVA/test files to
  make a test "pass" in the report — it only reports what the sim log
  already says. A test showing `fail` here with an open `BUG-xxx` in
  `FIX.md` is expected and correct.
