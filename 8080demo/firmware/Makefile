# usage e.g.:
# make FIRMWARE_IMG=test 

ASM = ../../asm8080/mac/asm8080
SRECCAT = srec_cat

all: $(FIRMWARE_IMG).hex $(FIRMWARE_IMG).vhex

$(FIRMWARE_IMG).hex:
	ASM $(FIRMWARE_IMG).asm

$(FIRMWARE_IMG).vhex:
	SRECCAT $(FIRMWARE_IMG).hex -intel -o $(FIRMWARE_IMG).vhex -VMem 8

# ./asm8080 ../../projects/iCE40HX1K-EVB/8080test/firmware/test.asm
# 