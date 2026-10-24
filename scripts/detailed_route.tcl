# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

read_db $ROOT/alu4_global_route.odb
read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

read_guides $ROOT/alu4_route.guide

detailed_route \
    -output_drc $ROOT/alu4_drc.rpt \
    -output_maze $ROOT/alu4_maze.log \
    -verbose 1

write_db $ROOT/alu4_routed.odb
write_def $ROOT/alu4_routed.def
