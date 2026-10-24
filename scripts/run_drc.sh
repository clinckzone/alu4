#!/usr/bin/env bash
set -euo pipefail

# Run from the project root, one level above this script.
cd "$(dirname "$0")/.."

FLOW_HOME="${FLOW_HOME:-/OpenROAD-flow-scripts/flow}"
PLATFORM="$FLOW_HOME/platforms/nangate45"

INPUT_GDS="alu4.gds"
DRC_REPORT="alu4_drc.lyrdb"
DRC_RULES="$PLATFORM/drc/FreePDK45.lydrc"

# Verify required inputs exist.
test -f "$INPUT_GDS" || {
  echo "ERROR: Missing $INPUT_GDS. Run generate_gds.sh first."
  exit 1
}

test -f "$DRC_RULES" || {
  echo "ERROR: Missing DRC rule deck: $DRC_RULES"
  exit 1
}

# Remove stale results before running.
rm -f "$DRC_REPORT"

echo "Running KLayout DRC on $INPUT_GDS..."

klayout -b \
  -rd in_gds="$INPUT_GDS" \
  -rd report_file="$DRC_REPORT" \
  -r "$DRC_RULES"

# Verify report generation.
test -s "$DRC_REPORT" || {
  echo "ERROR: DRC report was not generated."
  exit 1
}

echo "DRC completed."
echo "Report: $DRC_REPORT"
