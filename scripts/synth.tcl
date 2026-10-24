yosys -import

# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

set LIBERTY $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

read_verilog $ROOT/rtl/alu4.v
synth -top alu4

# Map generic gates onto Nangate45 standard cells
dfflibmap -liberty $LIBERTY
abc -liberty $LIBERTY
opt_clean

stat -liberty $LIBERTY

write_verilog -noattr $ROOT/alu4_mapped.v
