# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

read_db $ROOT/alu4_powered.odb
read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

set_routing_layers -signal metal2-metal10

global_route -guide_file $ROOT/alu4_route.guide

write_db $ROOT/alu4_global_route.odb
