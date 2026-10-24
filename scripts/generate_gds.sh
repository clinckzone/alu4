#!/usr/bin/env bash
set -euo pipefail

# Run from the project root, one level above this script.
cd "$(dirname "$0")/.."

FLOW_HOME="${FLOW_HOME:-/OpenROAD-flow-scripts/flow}"
PLATFORM="$FLOW_HOME/platforms/nangate45"

# 1. Generate a KLayout technology configuration.
python3 "$FLOW_HOME/util/generate_klayout_tech.py" \
  --template "$PLATFORM/FreePDK45.lyt" \
  --output alu4_klayout.lyt \
  --lef-files \
    "$PLATFORM/lef/NangateOpenCellLibrary.tech.lef" \
    "$PLATFORM/lef/NangateOpenCellLibrary.macro.lef"

# 2. Merge our routed DEF with standard-cell GDS geometry.
klayout -b \
  -rd design_name=alu4 \
  -rd in_def=alu4_routed.def \
  -rd in_files="$PLATFORM/gds/NangateOpenCellLibrary.gds" \
  -rd out_file=alu4.gds \
  -rd tech_file=alu4_klayout.lyt \
  -rd layer_map="" \
  -rd seal_file="" \
  -r "$FLOW_HOME/util/def2stream.py"

# 3. Check that an output file was generated.
test -s alu4.gds

echo "GDS generation completed: alu4.gds"
