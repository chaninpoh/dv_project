#!/usr/bin/env python3
"""Generate the LED MUX CONTROLLER HVP verification plan and run urg -xmlplan.

Pipeline (Synopsys Verification Planner, see v_planner.pdf):
  1. Read the test list (feature/subfeature/test/priority/goal) from
     scripts/generate_testplan.py — the single source of truth already used
     to build LED_MUX_CONTROLLER_testplan.xlsx.
  2. Determine each test's pass/fail status from its sim log
     (LED_MUX_CONTROLLER_stu/sim/<test>_seed_*_sim.log), using the same gate
     criteria as CLAUDE.md Rule 6 (phase marker present, UVM_ERROR==0,
     UVM_FATAL==0).
  3. Emit an HVP plan file (led_mux_controller_testplan.hvp) describing the
     feature hierarchy, one `measure test` per test, and one coverage
     measure (SnpsAvg/Line/...) sourced from the DUT instance tree.
  4. Emit an HVP userdata file with the pass/fail results for the `test`
     built-in metric (there is no Execution Manager in this flow, so test
     results are supplied as external user data).
  5. Run `urg -dir dut_simv.vdb -plan <plan>.hvp -userdata <userdata>
     -xmlplan -report urgReport` to produce urgReport/plan.xml, and copy it
     to sim/testplan.xml.
"""
import argparse
import glob
import os
import re
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "..", ".."))
STU = os.path.join(REPO_ROOT, "LED_MUX_CONTROLLER_stu")
SIM = os.path.join(STU, "sim")
PROJ_SETUP = os.path.join(STU, "proj1.setup")
VDB = os.path.join(SIM, "dut_simv.vdb")

sys.path.insert(0, os.path.join(REPO_ROOT, "scripts"))
try:
    import openpyxl  # noqa: F401
except ImportError:
    # generate_testplan.py only needs openpyxl for its xlsx-writing main(),
    # which this script never calls — stub it so the data-only import works
    # without requiring openpyxl to be installed for this interpreter.
    import types
    stub = types.ModuleType("openpyxl")
    stub.utils = types.ModuleType("openpyxl.utils")
    stub.utils.get_column_letter = lambda i: ""
    stub.load_workbook = lambda *a, **k: None
    styles_stub = types.ModuleType("openpyxl.styles")
    styles_stub.Alignment = lambda *a, **k: None
    sys.modules["openpyxl"] = stub
    sys.modules["openpyxl.styles"] = styles_stub

from generate_testplan import ROWS, PLAN_NAME, filter_rows_by_tier  # noqa: E402

PHASE_RE_TMPL = r"PHASE\s*3\s*:\s*P0\s+{test}\b"
UVM_ERROR_RE = re.compile(r"UVM_ERROR\s*:\s*(\d+)")
UVM_FATAL_RE = re.compile(r"UVM_FATAL\s*:\s*(\d+)")


def sanitize(name: str) -> str:
    s = re.sub(r"[^0-9A-Za-z_]+", "_", name.strip())
    s = re.sub(r"_+", "_", s).strip("_")
    if not s:
        s = "feature"
    if s[0].isdigit():
        s = "f_" + s
    return s


def hvp_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def uniquify(base: str, seen: set) -> str:
    name = base
    n = 2
    while name in seen:
        name = f"{base}_{n}"
        n += 1
    seen.add(name)
    return name


def test_status(test_name: str) -> str:
    """Return 'pass', 'fail', or None (not yet run) per CLAUDE.md Rule 6 gate."""
    logs = sorted(
        glob.glob(os.path.join(SIM, f"{test_name}_seed_*_sim.log")),
        key=os.path.getmtime,
    )
    if not logs:
        return None
    text = open(logs[-1], errors="ignore").read()
    if not re.search(PHASE_RE_TMPL.format(test=re.escape(test_name)), text):
        return "fail"
    err = UVM_ERROR_RE.findall(text)
    fatal = UVM_FATAL_RE.findall(text)
    if not err or not fatal:
        return "fail"
    if int(err[-1]) != 0 or int(fatal[-1]) != 0:
        return "fail"
    return "pass"


def build_tree(rows):
    """Group ROWS into {top_feature: [row, ...]}, carrying forward blank top features."""
    tree = {}
    current_top = None
    for row in rows:
        feat = row[0].strip()
        if feat:
            current_top = feat
        tree.setdefault(current_top, []).append(row)
    return tree


def emit_plan(rows, owner: str, line_goal: int) -> str:
    tree = build_tree(rows)
    lines = []
    lines.append(f"plan {PLAN_NAME};")
    lines.append("  annotation string priority = \"\";")
    lines.append("  annotation string goal_ref = \"\";")
    lines.append("")

    top_seen = set()
    for top_feat, feat_rows in tree.items():
        top_id = uniquify(sanitize(top_feat), top_seen)
        lines.append(f"  feature {top_id};")
        lines.append(f"    description = {hvp_str(top_feat)};")
        if owner:
            lines.append(f"    owner = {hvp_str(owner)};")
        lines.append("")

        sub_seen = set()
        for feat, sub, test, flow, constraints, checkers, code_cov, typ, pri, goal in feat_rows:
            sub_id = uniquify(sanitize(sub), sub_seen)
            lines.append(f"    feature {sub_id};")
            lines.append(f"      description = {hvp_str(sub)};")
            lines.append(f"      priority = {hvp_str(pri)};")
            lines.append(f"      goal_ref = {hvp_str(goal)};")
            lines.append(f"      measure test t_{sanitize(test)};")
            lines.append(f"        source = {hvp_str(test)};")
            lines.append("      endmeasure")
            lines.append("      test = (test.fail == 0);")
            lines.append("    endfeature")
            lines.append("")
        lines.append("  endfeature")
        lines.append("")

    lines.append("  feature Code_and_Functional_Coverage;")
    lines.append('    description = "DUT code and functional coverage (top_tb.dut_inst)";')
    lines.append("    measure SnpsAvg, Line, Cond, Toggle, FSM, Branch, Assert dut_cov;")
    lines.append('      source = "tree: top_tb.dut_inst";')
    lines.append("    endmeasure")
    lines.append(f"    Line = Line >= {line_goal}%;")
    lines.append("  endfeature")
    lines.append("endplan")
    return "\n".join(lines) + "\n"


def emit_userdata(rows) -> tuple:
    entries = []
    not_run = []
    seen = set()
    for row in rows:
        test = row[2]
        if test in seen:
            continue
        seen.add(test)
        status = test_status(test)
        if status is None:
            not_run.append(test)
        else:
            entries.append((test, status))
    lines = ["# Auto-generated by generate_hvp_testplan.py — test pass/fail from sim logs", "HVP metric = test"]
    for test, status in entries:
        lines.append(f"{test} = {status}")
    return "\n".join(lines) + "\n", entries, not_run


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--owner", default="", help="Owner annotation for all features")
    ap.add_argument("--tier", default="all", choices=["p0", "p1", "p2", "all"])
    ap.add_argument("--line-goal", type=int, default=80, help="Line coverage goal percent (default 80)")
    args = ap.parse_args()

    if not os.path.isdir(VDB):
        print(f"ERROR: coverage database not found at {VDB}", file=sys.stderr)
        print("Run at least one test first: make dv TESTNAME=<test> SEED=0", file=sys.stderr)
        sys.exit(1)

    rows = filter_rows_by_tier(ROWS, args.tier)

    hvp_text = emit_plan(rows, args.owner, args.line_goal)
    hvp_path = os.path.join(SIM, f"{PLAN_NAME}.hvp")
    with open(hvp_path, "w") as f:
        f.write(hvp_text)
    print(f"Wrote {hvp_path}")

    userdata_text, ran, not_run = emit_userdata(rows)
    userdata_path = os.path.join(SIM, "test_results.hvpdata")
    with open(userdata_path, "w") as f:
        f.write(userdata_text)
    print(f"Wrote {userdata_path} ({len(ran)} tests with results, {len(not_run)} not yet run)")
    if not_run:
        print("  Not yet run: " + ", ".join(not_run))

    report_dir = os.path.join(SIM, "urgReport")
    cmd = (
        f"cd {STU} && source {PROJ_SETUP} >/dev/null 2>&1 && cd sim && "
        f"urg -dir dut_simv.vdb -plan {hvp_path} -userdata {userdata_path} "
        f"-xmlplan -report {report_dir}"
    )
    result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)
    print(result.stdout[-4000:])
    if result.returncode != 0 or "Error-" in result.stdout:
        print(result.stderr[-4000:], file=sys.stderr)
        sys.exit(1)

    plan_xml = os.path.join(report_dir, "plan.xml")
    final_xml = os.path.join(SIM, "testplan.xml")
    if os.path.exists(plan_xml):
        with open(plan_xml) as src, open(final_xml, "w") as dst:
            dst.write(src.read())
        print(f"\ntestplan.xml written to: {final_xml}")
        print(f"(also available at: {plan_xml})")
    else:
        print("ERROR: urg did not produce plan.xml", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
