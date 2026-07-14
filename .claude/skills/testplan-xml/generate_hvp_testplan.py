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
     feature hierarchy, one `measure Group` per test (a percent-type built-in
     metric, goal Group >= 100%), and one coverage measure (SnpsAvg/Line/...)
     sourced from the DUT instance tree.
  4. Emit an HVP userdata file with the pass/fail results as percent values
     for the `Group` built-in metric — 100% on pass, 0% on fail (there is no
     Execution Manager in this flow, so test results are supplied as
     external user data, per v_planner.pdf's "External User Data" section).
  5. Auto-derive per-row SVA/covergroup measures: each ROW's `checkers`
     field (scripts/generate_testplan.py) already names the SVA
     assert/cover properties and covergroups that test exercises — the
     same text used to populate the "Assertions/Cover property" and
     "Covergroups" columns of LED_MUX_CONTROLLER_testplan.xlsx. This script
     resolves those names against labels parsed live from tb/sva/*.sv
     (assert/cover property directives, instance path found via the `bind`
     statement in tb/top_tb.sv) and tb/led_coverage.sv (covergroup/
     coverpoint/cross names), then emits one `measure Assert, AssertResult`
     or `measure Group` per resolved item, attached to that same test's
     feature — via the `property:` / `group:` source keywords (v_planner.pdf
     "Source Formats for Built-In Metrics", Table 1-4). This makes the
     testplan's per-row checker list "live" (pass/fail, hit/miss from the
     merged coverage database) instead of static text.
  6. Run `urg -dir dut_simv.vdb -plan <plan>.hvp -userdata <userdata>
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
TOP_TB_PATH = os.path.join(STU, "tb", "top_tb.sv")
SVA_DIR = os.path.join(STU, "tb", "sva")
COV_FILE = os.path.join(STU, "tb", "led_coverage.sv")

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

from generate_testplan import (  # noqa: E402
    ROWS,
    PLAN_NAME,
    filter_rows_by_tier,
    parse_checkers,
)

PHASE_RE_TMPL = r"PHASE\s*3\s*:\s*P0\s+{test}\b"
UVM_ERROR_RE = re.compile(r"UVM_ERROR\s*:\s*(\d+)")
UVM_FATAL_RE = re.compile(r"UVM_FATAL\s*:\s*(\d+)")
BIND_RE = re.compile(r"^\s*bind\s+(\w+)\s+(\w+)\s+(\w+)\s*\(", re.MULTILINE)
MODULE_RE = re.compile(r"^\s*module\s+(\w+)", re.MULTILINE)
SVA_LABEL_RE = re.compile(r"^\s*(\w+)\s*:\s*(assert|cover)\s+property\s*\(", re.MULTILINE)
COVERGROUP_RE = re.compile(r"covergroup\s+(\w+)\b.*?endgroup", re.DOTALL)
COVERPOINT_RE = re.compile(r"^\s*(\w+)\s*:\s*coverpoint\b", re.MULTILINE)
CROSS_RE = re.compile(r"^\s*(\w+)\s*:\s*cross\b", re.MULTILINE)

# TESTPLAN.md §0.3 documents this cover property as "check_60_80_cycle" (its
# checkers-field name across ROWS), but tb/sva/led_mux_sva.sv implements it as
# `cover_seg_change_latency`. This is a documented naming drift between the
# testplan and the SVA source, not a typo to silently paper over — bridge it
# here so annotation still resolves, and it still surfaces via `--tier all`
# unresolved-token warnings if the alias itself ever goes stale.
SVA_TOKEN_ALIASES = {"check_60_80_cycle": "cover_seg_change_latency"}


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


def derive_sva_bind_paths() -> dict:
    """Parse tb/top_tb.sv `bind <target_inst> <module> <bind_inst> (...)` statements.

    Returns {module_name: "top_tb.<target_inst>.<bind_inst>"} so SVA modules
    bound into the DUT hierarchy can be located without hardcoding instance
    paths (v_planner.pdf property: source needs the full instance path).
    """
    text = open(TOP_TB_PATH).read()
    return {
        module: f"top_tb.{target}.{inst}"
        for target, module, inst in BIND_RE.findall(text)
    }


def derive_sva_labels() -> tuple:
    """Parse tb/sva/*.sv for `<label>: assert property (...)` / `<label>: cover
    property (...)` directives and pair each with its full instance path.

    Returns (asserts, covers), each a list of (label, source_path) tuples.
    """
    bind_paths = derive_sva_bind_paths()
    asserts, covers = [], []
    for path in sorted(glob.glob(os.path.join(SVA_DIR, "*.sv"))):
        text = open(path).read()
        m = MODULE_RE.search(text)
        inst_path = bind_paths.get(m.group(1)) if m else None
        if not inst_path:
            continue
        for label, kind in SVA_LABEL_RE.findall(text):
            entry = (label, f"{inst_path}.{label}")
            (asserts if kind == "assert" else covers).append(entry)
    return asserts, covers


def derive_covergroups() -> dict:
    """Parse tb/led_coverage.sv `covergroup <name> ... endgroup` blocks.

    Returns {cg_name: [coverpoint_or_cross_name, ...]} so per-row `COV cg_*`
    checker tokens can be expanded to their actual coverpoints/crosses
    (v_planner.pdf group: keyword supports "covergroup.coverpoint").
    """
    text = open(COV_FILE).read()
    groups = {}
    for m in COVERGROUP_RE.finditer(text):
        body = m.group(0)
        name = m.group(1)
        groups[name] = COVERPOINT_RE.findall(body) + CROSS_RE.findall(body)
    return groups


def resolve_sva_token(token: str, registry: dict) -> list:
    """Resolve one checkers-field SVA token to [(label, source_path), ...].

    Tokens are usually an exact assert/cover property label. Two documented
    exceptions: SVA_TOKEN_ALIASES (naming drift between TESTPLAN.md and the
    SVA source), and family prefixes like "cover_seg_out_decimal_digit" that
    stand in for cover_seg_out_decimal_digit_0..9. Returns [] if nothing
    matches, so callers can report it instead of silently dropping it.
    """
    token = SVA_TOKEN_ALIASES.get(token, token)
    if token in registry:
        return [(token, registry[token])]
    prefix_matches = sorted(
        (label, path) for label, path in registry.items()
        if label.startswith(token + "_")
    )
    return prefix_matches


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


def emit_plan(rows, owner: str, line_goal: int) -> tuple:
    tree = build_tree(rows)

    sva_asserts, sva_covers = derive_sva_labels()
    sva_registry = dict(sva_asserts + sva_covers)
    covergroups = derive_covergroups()

    unresolved_sva = set()
    unresolved_cov = set()

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
            lines.append(f"      measure Group g_{sanitize(test)};")
            lines.append(f"        source = {hvp_str(test)};")
            lines.append("      endmeasure")
            lines.append("      Group = Group >= 100%;")

            sva, cov, _scb = parse_checkers(checkers)
            sva_tokens = [t.strip() for entry in sva for t in entry.split(",") if t.strip()]
            cov_tokens = [t.strip() for entry in cov for t in entry.split(",") if t.strip()]

            emitted = set()
            for token in sva_tokens:
                matches = resolve_sva_token(token, sva_registry)
                if not matches:
                    unresolved_sva.add(token)
                    continue
                for label, source_path in matches:
                    if label in emitted:
                        continue
                    emitted.add(label)
                    lines.append(f"      measure Assert, AssertResult m_{sanitize(label)};")
                    lines.append(f'        source = {hvp_str(f"property: {source_path}")};')
                    lines.append("      endmeasure")

            for cg in cov_tokens:
                if cg not in covergroups:
                    unresolved_cov.add(cg)
                    continue
                if cg not in emitted:
                    emitted.add(cg)
                    lines.append(f"      measure Group m_{sanitize(cg)};")
                    lines.append(f'        source = {hvp_str(f"group: {cg}")};')
                    lines.append("      endmeasure")
                for cp in covergroups[cg]:
                    key = f"{cg}.{cp}"
                    if key in emitted:
                        continue
                    emitted.add(key)
                    lines.append(f"      measure Group m_{sanitize(cg)}_{sanitize(cp)};")
                    lines.append(f'        source = {hvp_str(f"group: {cg}.{cp}")};')
                    lines.append("      endmeasure")

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
    return "\n".join(lines) + "\n", unresolved_sva, unresolved_cov


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
    lines = ["# Auto-generated by generate_hvp_testplan.py — test pass/fail from sim logs", "HVP metric = Group"]
    for test, status in entries:
        pct = "100%" if status == "pass" else "0%"
        lines.append(f"{test} = {pct}")
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

    hvp_text, unresolved_sva, unresolved_cov = emit_plan(rows, args.owner, args.line_goal)
    hvp_path = os.path.join(SIM, f"{PLAN_NAME}.hvp")
    with open(hvp_path, "w") as f:
        f.write(hvp_text)
    print(f"Wrote {hvp_path}")
    if unresolved_sva:
        print(
            "  WARNING: checkers-field SVA tokens with no matching tb/sva/*.sv "
            "label (not annotated): " + ", ".join(sorted(unresolved_sva)),
            file=sys.stderr,
        )
    if unresolved_cov:
        print(
            "  WARNING: checkers-field COV tokens with no matching covergroup "
            "in tb/led_coverage.sv (not annotated): " + ", ".join(sorted(unresolved_cov)),
            file=sys.stderr,
        )

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
