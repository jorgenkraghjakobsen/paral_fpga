#BOARD=tangnano20k
#FAMILY=GW2AR-9C
#3DEVICE=GW2AR-LV18QN88C8/I7

BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

PRO=counter

all: $(PRO).fs

# Synthesis
$(PRO).json: $(PRO).v
	yosys -p "read_verilog $(PRO).v; synth_gowin -top $(PRO) -json $(PRO).json"

#/home/jakobsen/oss-cad-suite/bin/yosys -p "read_verilog counter.v; synth_gowin -top counter -json counter.json"

# Place and Route
$(PRO)_pnr.json: $(PRO).json
	nextpnr-gowin --json $(PRO).json --freq 27 --write $(PRO)_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
$(PRO).fs: $(PRO)_pnr.json
	gowin_pack -d ${FAMILY} -o $(PRO).fs $(PRO)_pnr.json

# Program Board
load: $(PRO).fs
	openFPGALoader -b ${BOARD} $(PRO).fs -f

.PHONY: load
.INTERMEDIATE: $(PRO)_pnr.json $(PRO).json

synth:
	echo "read_verilog $(PRO).v" > yosys.cmd ;\
	echo "synth_gowin -top $(PRO) -json $(PRO).json" >> yosys.cmd ;\
	yosys -s yosys.cmd

place:
	nextpnr-gowin --json $(PRO).json --freq 27 --write $(PRO)_pnr.json \
	--device ${DEVICE} --family ${FAMILY} --cst $(PRO).cst

#    GW2AR-LV18QN88C8/I7
bit:	
	gowin_pack -d ${FAMILY} -o $(PRO).fs $(PRO)_pnr.json 

prog:
	openFPGALoader -b ${BOARD} -f $(PRO).fs