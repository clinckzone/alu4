# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

read_lef $PLATFORM/lef/NangateOpenCellLibrary.tech.lef
read_lef $PLATFORM/lef/NangateOpenCellLibrary.macro.lef

read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

read_verilog $ROOT/alu4_mapped.v
link_design alu4

initialize_floorplan \
    -die_area {0 0 20 20} \
    -core_area {2 2 18 18} \
    -site FreePDK45_38x28_10R_NP_162NW_34O

make_tracks
place_pins -hor_layers metal3 -ver_layers metal2
global_placement -density 0.40
detailed_placement
		
write_db $ROOT/alu4_floorplan.odb
write_def $ROOT/alu4_floorplan.def
