#!/usr/bin/env bash
set -euo pipefail
COMP_LOG="${1:-dut_comp.log}"
SIM_LOG="${2:-smoke_test_seed_0_sim.log}"
TESTNAME="${3:-smoke_test}"
PHASE_MARK="PHASE 3 : P0 ${TESTNAME}"

fail() { echo "GATE FAIL [$TESTNAME]: $1"; exit 1; }

[[ -f "$COMP_LOG" ]] || fail "missing compile log: $COMP_LOG"
[[ -f "$SIM_LOG"   ]] || fail "missing sim log: $SIM_LOG"

grep -q "$PHASE_MARK" "$SIM_LOG" || fail "phase marker not found: '$PHASE_MARK'"
grep -q "UVM_ERROR" "$COMP_LOG" && fail "UVM_ERROR in compile log"
grep -q "UVM_ERROR" "$SIM_LOG"   && fail "UVM_ERROR in sim log"
grep -qiE "error-|syntax error" "$COMP_LOG" && fail "compile errors in $COMP_LOG"
grep -q "UVM_FATAL" "$SIM_LOG" && fail "UVM_FATAL in sim log"
grep -qE "${TESTNAME}|uvm_test_top" "$SIM_LOG" || fail "test not visible in topology/factory dump"

echo "GATE PASS: P0 $TESTNAME"
