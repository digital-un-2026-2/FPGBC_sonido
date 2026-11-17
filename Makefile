TARGET=top
TOP=top

ICE40_SIM_CELLS=./lattice_sim/cells_sim_ecp5.v


COMM_OBJS+=top.v
SIM_OBJS =  ../../verilog_model/sky130_fd_sc_hd.v
SIM_OBJS += ../../verilog_model/primitives.v

PER_OBJS = ../perip_test.v $(OBJS)

BUILD_DIR = build

all: sim

sim:
	rm -f a.out *.vcd
	iverilog -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27  $(TARGET)_TB.v $(COMM_OBJS)
	vvp a.out
	gtkwave $(TARGET)_TB.vcd
sim_per:
	rm -f a.out *.vcd
	iverilog -I ./lattice_sim  perip_$(TARGET)_TB.v $(PER_OBJS)
	vvp a.out
	gtkwave perip_$(TARGET)_TB.vcd &
$(TOP).json:
	yosys -v3 -l synth.log -p 'synth_ecp5 -top $(TARGET) -json $(TARGET).json; write_verilog -attr2comment $(TARGET)_synth.v' $(OBJS)

## ---------------------
## post-synth simulation
## ---------------------
sim_post_syn: $(TOP).json $(OBJS)
	iverilog -I ./lattice_sim -o $@_PS.vpp -s $(TOP)_TB $(TARGET)_TB.v $(TOP)_synth.v $(ICE40_SIM_CELLS) 
	vvp $@_PS.vpp
	gtkwave $(TOP)_TB.vcd &
sim_post_syn_sky:
	yosys -l synth.log -c synth.tcl
	cp out.v $(TOP)_synth_sky.v 
	iverilog -DFUNCTIONAL -DUNIT_DELAY=#1 -o $@_PS.vpp -s $(TOP)_TB $(TARGET)_TB.v $(TOP)_synth_sky.v ${SIM_OBJS}
	vvp $@_PS.vpp
	./$@_PS.vpp
	gtkwave $(TOP)_TB.vcd &
	#netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
	

## ---------------------
## post-route simulation
## ---------------------
$(TOP).asc: $(TOP).json
#	nextpnr-ecp5 --hx8k --package ct256 --json $(TOP).json --pcf $(TOP).pcf --asc $@  --routed-svg $(TOP)_routed.svg --placed-svg $(TOP)_placed.svg #--pcf-allow-unconstrained
	nextpnr-ecp5 --json $< --lpf $(TOP).lpf --textcfg $@ --25k --package CABGA381 --speed 6  --timing-allow-fail --seed 1 --lpf-allow-unconstrained --routed-svg $(TOP)_routed.svg --placed-svg $(TOP)_placed.svg

$(TOP).config: $(TOP).json
	nextpnr-ecp5 --json $< --lpf $(TOP).lpf --textcfg $@ --25k --package CABGA381 --speed 6  --timing-allow-fail --seed 1 --lpf-allow-unconstrained

$(TOP).bit: $(TOP).config
	ecppack --bootaddr 0 --compress $< --svf ${TOP}.svf --bit $@

sim_post_route: $(TOP).asc $(TOP).pcf $(TOP).bit
	ecpunpack $(TOP).bit $(TOP).tcf
#	iverilog -o $@.vpp -s $(TOP)_TB $(TARGET)_post_route_TB.v  $(TOP)_route.v  $(ICE40_SIM_CELLS)
#	chmod -x $@
#	vvp $@.vpp
#	gtkwave $(TOP)_TB.vcd &

svg: $(OBJS)
	yosys -p "prep -top ${TARGET}; write_json ${TARGET}.json" ${OBJS}
	netlistsvg ${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
	yosys -p "prep -top ${TARGET} -flatten; write_json ${TARGET}_flat.json" ${OBJS}
	netlistsvg ${TARGET}_flat.json -o ${TARGET}_flat.svg  #--skin default.svg


PRIMER_OPEN_BIN ?= /home/vargas/Digital_II/FPGBC_digital_UN/.pixi/envs/default/bin
PRIMER_YOSYS ?= $(PRIMER_OPEN_BIN)/yosys
PRIMER_NEXTPNR ?= $(PRIMER_OPEN_BIN)/nextpnr-himbaechel-gowin
PRIMER_PACK ?= $(PRIMER_OPEN_BIN)/gowin_pack
PRIMER_BUILD_DIR ?= $(BUILD_DIR)/primer25k_open
PRIMER_FTDI_SERIAL ?= 2025030317

EQ144_OPEN_BIN ?= $(PRIMER_OPEN_BIN)
EQ144_YOSYS ?= yosys
EQ144_NEXTPNR ?= $(EQ144_OPEN_BIN)/nextpnr-himbaechel-gowin
EQ144_PACK ?= $(EQ144_OPEN_BIN)/gowin_pack
EQ144_BUILD_DIR ?= $(BUILD_DIR)/gw2ar_eq144_open
EQ144_FTDI_SERIAL ?=
EQ144_JTAG_FREQ ?= 1000000

.PHONY: build_gw2ar_eq144 configure_gw2ar_eq144

build_gw2ar_eq144: $(COMM_OBJS) gw2ar_eq144.cst gw2ar_eq144.sdc
	mkdir -p "$(EQ144_BUILD_DIR)"
	"$(EQ144_YOSYS)" -Q -T -q -l $(EQ144_BUILD_DIR)/$(TOP)_synth.log -p 'read_verilog $(COMM_OBJS); synth_gowin -family gw2a -top $(TOP) -json $(EQ144_BUILD_DIR)/$(TOP)_synth.json; check -assert'
	"$(EQ144_NEXTPNR)" --device GW2AR-LV18EQ144PC8/I7 --top $(TOP) --json $(EQ144_BUILD_DIR)/$(TOP)_synth.json --write $(EQ144_BUILD_DIR)/$(TOP)_pnr.json --sdc gw2ar_eq144.sdc --freq 25 --vopt family=GW2A-18C --vopt cst=gw2ar_eq144.cst --seed 1 --report $(EQ144_BUILD_DIR)/$(TOP)_report.json --log $(EQ144_BUILD_DIR)/$(TOP)_pnr.log
	"$(EQ144_PACK)" -d GW2A-18C -o $(EQ144_BUILD_DIR)/$(TOP).fs $(EQ144_BUILD_DIR)/$(TOP)_pnr.json

configure_gw2ar_eq144: build_gw2ar_eq144
	sudo openFPGALoader --cable ft232RL --pins TXD:CTS:DTR:RXD --freq $(EQ144_JTAG_FREQ) $(if $(strip $(EQ144_FTDI_SERIAL)),--ftdi-serial "$(EQ144_FTDI_SERIAL)") --write-sram --bitstream $(EQ144_BUILD_DIR)/$(TOP).fs




clean:
	rm -rf *.out *.vcd *.svg *.json $(TOP)_synth.v *.vpp *.asc $(TOP)_route.v synth.log


#https://stackoverflow.com/questions/35927650/is-it-possible-to-create-a-simulation-waveform-from-yosys-output

