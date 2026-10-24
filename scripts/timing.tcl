# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

# Physical technology: layers and vias
read_lef $PLATFORM/lef/NangateOpenCellLibrary.tech.lef

# Physical standard cells: dimensions and pin positions
read_lef $PLATFORM/lef/NangateOpenCellLibrary.macro.lef

# Logical and timing models
read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

# Our synthesized ALU
read_verilog $ROOT/alu4_mapped.v
link_design alu4

# Define a virtual clock for timing constraints
create_clock -name virtual_clk -period 1.0

set_input_delay 0 -clock virtual_clk [all_inputs]
set_output_delay 0 -clock virtual_clk [all_outputs]

# Define electrical assumptions
set_input_transition 0.05 [all_inputs]
set_load 0.01 [all_outputs]

# Report timing
report_checks -path_delay max -group_path_count 5 \
    -fields {slew cap input nets fanout}
