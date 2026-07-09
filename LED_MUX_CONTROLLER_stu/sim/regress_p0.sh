#!/usr/bin/env bash
# P0 regression batch — all 11 essential tests (TESTPLAN §1.1)
# Usage: ./regress_p0.sh   (run from sim/ on course Linux VM)
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
