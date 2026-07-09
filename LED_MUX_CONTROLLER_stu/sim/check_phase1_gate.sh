#!/usr/bin/env bash
# Phase 1 review gate — usage: ./check_phase1_gate.sh [comp_log] [sim_log]
set -euo pipefail

COMP_LOG="${1:-dut_comp.log}"
SIM_LOG="${2:-phase1_tb_top_test_seed_0_sim.log}"
PHASE_MARK="PHASE 1 : testbench top"

fail() { echo "GATE FAIL: $1"; exit 1; }
pass() { echo "GATE PASS: Phase 1 review gate — $SIM_LOG"; }

[[ -f "$COMP_LOG" ]] || fail "compile log not found: $COMP_LOG"
[[ -f "$SIM_LOG"   ]] || fail "sim log not found: $SIM_LOG"

grep -q "$PHASE_MARK" "$SIM_LOG" \
  || fail "phase marker not found in $SIM_LOG (expect UVM_INFO with '$PHASE_MARK')"

grep -q "UVM_ERROR" "$COMP_LOG" && fail "UVM_ERROR found in $COMP_LOG"
grep -q "UVM_ERROR" "$SIM_LOG"   && fail "UVM_ERROR found in $SIM_LOG"

grep -qiE "error-|syntax error" "$COMP_LOG" \
  && fail "VCS error keyword found in $COMP_LOG"

grep -q "UVM_FATAL" "$SIM_LOG" && fail "UVM_FATAL found in $SIM_LOG"

pass
