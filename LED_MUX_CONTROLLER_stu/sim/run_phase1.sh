# Run on course Linux VM (VCS required)
# Usage: ./run_phase1.sh

set -euo pipefail
cd "$(dirname "$0")/.."
source proj1.setup
cd sim
chmod +x check_phase1_gate.sh
make clean
make phase1 TESTNAME=phase1_tb_top_test SEED=0
