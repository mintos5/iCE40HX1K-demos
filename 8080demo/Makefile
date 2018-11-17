PROJ = l80soc
PIN_DEF = ice40hx1k-evb.pcf
DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top l80soc -blif $@' $<

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	sudo iceprogduino $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprogduino $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin $(PROJ).vvp $(PROJ).vcd

sim:
	iverilog -s tb_l80soc -o $(PROJ).vvp tb.v
	vvp $(PROJ).vvp

.PHONY: all prog clean sim
