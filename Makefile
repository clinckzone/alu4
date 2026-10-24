# RTL-to-GDS flow for alu4 on Nangate45.
# Run `make` for the whole flow, or `make <stage>` to stop at that stage.

FLOW_HOME ?= /OpenROAD-flow-scripts/flow
PLATFORM  ?= $(FLOW_HOME)/platforms/nangate45
export FLOW_HOME PLATFORM

YOSYS    ?= yosys
OPENROAD ?= openroad
IVERILOG ?= iverilog
VVP      ?= vvp

S := scripts

.PHONY: all help sim synth timing floorplan pdn global_route detailed_route \
        sta gds drc clean

all: drc sta

help:
	@echo "Stages, in flow order (each first runs the stages it depends on):"
	@echo "  sim             RTL simulation with Icarus Verilog"
	@echo "  synth           Yosys synthesis      -> alu4_mapped.v"
	@echo "  timing          Pre-layout STA (report only)"
	@echo "  floorplan       Floorplan + placement -> alu4_floorplan.odb"
	@echo "  pdn             Power grid           -> alu4_powered.odb"
	@echo "  global_route    Global routing       -> alu4_global_route.odb"
	@echo "  detailed_route  Detailed routing     -> alu4_routed.odb/.def"
	@echo "  sta             Post-route STA       -> alu4_routed.spef"
	@echo "  gds             Stream out           -> alu4.gds"
	@echo "  drc             KLayout DRC          -> alu4_drc.lyrdb"
	@echo "  all             Whole flow through drc and sta (default)"
	@echo "  clean           Remove all generated files"

# ---- Simulation ----

sim: build/alu4_tb.out
	$(VVP) $<

build/alu4_tb.out: rtl/alu4.v tb/alu4_tb.v
	@mkdir -p build
	$(IVERILOG) -o $@ $^

# ---- Stage aliases ----

synth:          alu4_mapped.v
floorplan:      alu4_floorplan.odb
pdn:            alu4_powered.odb
global_route:   alu4_global_route.odb
detailed_route: alu4_routed.odb
sta:            alu4_routed.spef
gds:            alu4.gds
drc:            alu4_drc.lyrdb

# ---- Flow ----

alu4_mapped.v: rtl/alu4.v $(S)/synth.tcl
	$(YOSYS) -c $(S)/synth.tcl

timing: alu4_mapped.v
	$(OPENROAD) -exit $(S)/timing.tcl

alu4_floorplan.odb: alu4_mapped.v $(S)/floorplan.tcl
	$(OPENROAD) -exit $(S)/floorplan.tcl

alu4_powered.odb: alu4_floorplan.odb $(S)/pdn.tcl
	$(OPENROAD) -exit $(S)/pdn.tcl

alu4_global_route.odb: alu4_powered.odb $(S)/routing.tcl
	$(OPENROAD) -exit $(S)/routing.tcl

# detailed_route.tcl writes both the .odb and the .def.
alu4_routed.odb: alu4_global_route.odb $(S)/detailed_route.tcl
	$(OPENROAD) -exit $(S)/detailed_route.tcl
alu4_routed.def: alu4_routed.odb ;

alu4_routed.spef: alu4_routed.odb $(S)/post_route_sta.tcl
	$(OPENROAD) -exit $(S)/post_route_sta.tcl

alu4.gds: alu4_routed.def $(S)/generate_gds.sh
	$(S)/generate_gds.sh

alu4_drc.lyrdb: alu4.gds $(S)/run_drc.sh
	$(S)/run_drc.sh

clean:
	rm -rf build
	rm -f alu4_mapped.v *.odb *.def *.guide *.spef *.gds *.lyrdb *.log \
	      alu4_drc.rpt alu4_klayout.lyt
