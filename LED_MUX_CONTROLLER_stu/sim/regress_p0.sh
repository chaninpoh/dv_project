#!/usr/bin/env bash
# Full regression (P0 + P1 + S-tests) — multi-seed per test
# smoke_test is EXCLUDED: run it manually only when testbench files change.
#
# Usage: ./regress_p0.sh [num_seeds]
#   num_seeds defaults to NUM_SEEDS below.
#   Tune NUM_SEEDS after reviewing coverage results.
#   Seeds used: 0 .. (num_seeds - 1)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"   # LED_MUX_CONTROLLER_stu/ — required so ROOT=`pwd` is correct
source proj1.setup
cd "$SCRIPT_DIR"                 # back to sim/

NUM_SEEDS=${1:-10}

# Timestamped output directory for this regression run
REGRESS_DIR="regress_$(date +%Y%m%d%H%M)"
mkdir -p "$REGRESS_DIR"
echo "=== Regression output: $REGRESS_DIR ==="

# All regression tests — smoke_test excluded (TB-change gate only)
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
  apb_default_enable_led_path_test
  led_reenable_after_disable_test
  led_max_displayable_test
  led_sel_onehot_scan_test
  led_hold_time_min_test
  led_latency_window_test
  full_display_flow_test
  apb_read_during_processing_test
  random_regression_test
  led_overflow_boundary_test
  led_overflow_max_test
  led_single_digit_zero_test
  led_single_digit_one_test
  led_seg_active_low_test
  led_back_to_back_error_test
  enable_off_overflow_test
  led_digit_sweep_test
)

# Compile once — abort immediately if it fails
echo "=== Compiling (once) ==="
make compile 2>&1 | tail -3
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  echo "ERROR: Compilation failed — aborting regression."
  exit 1
fi
cp dut_comp.log "$REGRESS_DIR/"
echo "=== Compilation done ==="
echo ""

PASS=0; FAIL=0; FAIL_LIST=()

# Extract UVM error/fatal counts from summary line in sim log.
# Returns 0 (pass) only when both counts are 0 and log exists.
check_log() {
  local log="$1"
  [[ -f "$log" ]] || return 1
  local err fat
  err=$(awk '/UVM_ERROR :/{val=$NF} END{printf "%d", val+0}' "$log")
  fat=$(awk '/UVM_FATAL :/{val=$NF} END{printf "%d", val+0}' "$log")
  [[ "$err" -eq 0 && "$fat" -eq 0 ]]
}

for t in "${P0_TESTS[@]}"; do
  for (( s=0; s<NUM_SEEDS; s++ )); do
    printf "%-48s  seed=%-3d  " "$t" "$s"
    SIM_LOG="${t}_seed_${s}_sim.log"
    make run TESTNAME="$t" SEED="$s" >/dev/null 2>&1
    cp "$SIM_LOG" "$REGRESS_DIR/" 2>/dev/null
    if check_log "$REGRESS_DIR/$SIM_LOG"; then
      echo "PASS"
      PASS=$(( PASS+1 ))
    else
      echo "FAIL"
      FAIL=$(( FAIL+1 ))
      FAIL_LIST+=("$t  seed=$s")
    fi
  done
done

TOTAL=$(( ${#P0_TESTS[@]} * NUM_SEEDS ))
echo ""
echo "=============================================="
echo " Full Regression P0+P1+S  (seeds 0..$((NUM_SEEDS-1)))"
echo " Output : $REGRESS_DIR"
echo "=============================================="
printf " Tests      : %d\n"  "${#P0_TESTS[@]}"
printf " Seeds/test : %d\n"  "$NUM_SEEDS"
printf " Total runs : %d\n"  "$TOTAL"
printf " PASS       : %d\n"  "$PASS"
printf " FAIL       : %d\n"  "$FAIL"
if [[ $FAIL -gt 0 ]]; then
  echo " Failures:"
  for f in "${FAIL_LIST[@]}"; do printf "   - %s\n" "$f"; done
fi
echo "=============================================="

# Merge coverage from all sessions and generate report inside REGRESS_DIR
echo ""
echo "=== Merging coverage ==="
urg -dir dut_simv.vdb \
    -plan led_mux_controller_testplan.hvp \
    -userdata test_results.hvpdata \
    -xmlplan \
    -elfile tgl_waivers.cfg \
    -report "$REGRESS_DIR/urgReport"
echo "=== Coverage report: $REGRESS_DIR/urgReport ==="

if [[ $FAIL -gt 0 ]]; then
  echo "Result: FAIL — prompt agent: check logfiles for regress_p0"
  exit 1
fi
echo "Result: PASS — prompt agent: check logfiles for regress_p0"
