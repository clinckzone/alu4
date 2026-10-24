# Override with the PLATFORM environment variable if ORFS lives elsewhere.
if {[info exists ::env(PLATFORM)]} {
    set PLATFORM $::env(PLATFORM)
} else {
    set PLATFORM /OpenROAD-flow-scripts/flow/platforms/nangate45
}

# Inputs and outputs live in the project root, one level above this script.
set ROOT [file normalize [file join [file dirname [info script]] ..]]

read_db $ROOT/alu4_floorplan.odb
read_liberty $PLATFORM/lib/NangateOpenCellLibrary_typical.lib

# Connect standard-cell power and ground pins
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {^VDD$} -power
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {^VSS$} -ground

global_connect

# Define the voltage domain
set_voltage_domain -name CORE -power VDD -ground VSS

# Define our power grid
define_pdn_grid -name grid -voltage_domains CORE

# Metal1: standard-cell power rails
add_pdn_stripe -grid grid -layer metal1 \
    -width 0.17 -pitch 2.4 -offset 0 -followpins

# Metal4: intermediate power straps
add_pdn_stripe -grid grid -layer metal4 \
    -width 0.48 -pitch 6.0 -offset 1.0

# Metal7: higher-level power straps
add_pdn_stripe -grid grid -layer metal7 \
    -width 1.40 -pitch 8.0 -offset 1.0

# Connect layers using vias
add_pdn_connect -grid grid -layers {metal1 metal4}
add_pdn_connect -grid grid -layers {metal4 metal7}

# Generate and verify the power grid
pdngen
check_power_grid -net VDD -dont_require_terminals
check_power_grid -net VSS -dont_require_terminals

write_db $ROOT/alu4_powered.odb
