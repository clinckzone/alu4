# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

# Load our routed ALU
read_db $ROOT/alu4_routed.odb

# Load standard-cell timing models
read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

# Apply the same timing constraints as before
create_clock -name virtual_clk -period 1.0

set_input_delay 0 -clock virtual_clk [all_inputs]
set_output_delay 0 -clock virtual_clk [all_outputs]

set_input_transition 0.05 [all_inputs]
set_load 0.01 [all_outputs]

# Extract resistance and capacitance from routed wires
set_extraction_rules_file $PLATFORM/rcx_patterns.rules

extract_parasitics

write_spef $ROOT/alu4_routed.spef

read_spef $ROOT/alu4_routed.spef

report_parasitic_annotation

report_checks \
    -path_delay max \
    -group_path_count 2 \
    -digits 5 \
    -fields {slew cap input fanout}
