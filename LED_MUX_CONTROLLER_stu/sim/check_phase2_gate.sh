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
