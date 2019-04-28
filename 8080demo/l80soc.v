`include "power/pmu.v"
`include "power/cross_bus.v"
`include "power/cross_flag.v"
`include "intr_ctrl.v"
`include "light8080.v"
`include "micro_rom.v"
`include "osdvu/uart.v"
`include "membram.v"

//---------------------------------------------------------------------------------------
//	Project:			light8080 SOC		WiCores Solutions
//
//	File name:			l80soc.v 			(February 04, 2012)
//
//	Writer:				Moti Litochevski
//
//	Description:
//		This file contains the light8080 System On a Chip (SOC). the system includes the
//		CPU, program and data RAM and a UART interface and a general purpose digital IO.
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner>
//		<comment>
//
//---------------------------------------------------------------------------------------
//
//	Copyright (C) 2012 Moti Litochevski
//
//	This source file may be used and distributed without restriction provided that this
//	copyright statement is not removed from the file and that any derivative work
//	contains the original copyright notice and the associated disclaimer.
//
//	THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
//	INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE.
//
//---------------------------------------------------------------------------------------

module l80soc
(
	clock,
	txd, rxd, // RS232
	//p1dio, p2dio,
  	//din, ss, sck, dout, // SPI
	//extint, led1, led2
	led1, led2, led3, led4, led5
);
//---------------------------------------------------------------------------------------
// module interfaces
// global signals
input 			clock;		// global clock input
reg 			reset = 1'b1;		// global reset input
// uart serial signals
output			txd;		// serial data output
input			rxd;		// serial data input
// digital IO ports
// inout	[7:0]	p1dio;		// port 1 digital IO
// inout	[7:0]	p2dio;		// port 2 digital IO
//output	[7:0]	p1dio;		// port 1 digital IO
//output	[7:0]	p2dio;		// port 2 digital IO
// external interrupt sources
reg	[3:0]	extint;				// external interrupt sources
reg reset_state = 1'b1;	//reset state
reg [4:0] led_state = 5'd0;		// state of leds
output led1;
output led2;
output led3;
output led4;
output led5;
assign {led5, led4, led3, led2, led1} = led_state[4:0];

// SPI
// input din;
// output reg ss;
// output reg sck;
// output reg dout;

//---------------------------------------------------------------------------------------
// io space registers addresses
// uart registers
`define UDATA_REG			8'h80 		// used for both transmit and receive
`define UBAUDL_REG			8'h81		// low byte of baud rate register
`define UBAUDH_REG			8'h82		// low byte of baud rate register
`define USTAT_REG			8'h83		// uart status register
// dio port registers
`define P1_DATA_REG			8'h84		// port 1 data register
`define P1_DIR_REG			8'h85		// port 1 direction register
`define P2_DATA_REG			8'h86		// port 2 data register
`define P2_DIR_REG			8'h87		// port 2 direction register
// interrupt controller register
`define INTR_EN_REG			8'h88		// interrupts enable register

//`define SPI_TX_REG   		8'h90		// interrupts enable register
//`define SPI_RX_REG  		8'h90		// interrupts enable register
`define PMU_REG				8'h90		// used for setting the freq of CPU


//---------------------------------------------------------------------------------------
// internal declarations
// registered output

// internals
wire [15:0] cpu_addr;
wire [7:0] cpu_din, cpu_dout, ram_dout, intr_dout;
wire cpu_io, cpu_rd, cpu_wr, cpu_inta, cpu_inte, cpu_intr;
wire [7:0] txData, rxData;
wire [7:0] spiRxData;
wire txValid, txBusy, rxValid;

reg pmu_reset_state = 1'b1;	//reset state
reg pmu_reset = 1'b1;
always @ (posedge clock) 
begin
	if (pmu_reset_state) begin
		pmu_reset <= 1'b1;
		pmu_reset_state <= 1'b0;
	end
	else begin
		pmu_reset <= 1'b0;
	end
end

//---------------------------------------------------------------------------------------
// Start of auto generated components PMU + synchronizers
//---------------------------------------------------------------------------------------

wire pd_clk_0;
wire pd_clk_1;
wire level_flag_synced;
wire [3:0] level_synced;
wire power_mode_flag_synced;

power_manager pmu(
	.clk(clock),
	.reset(pmu_reset),
    .change_level_flag(level_flag_synced),
    .change_level(level_synced[2:0]),
    .change_power_mode_flag(power_mode_flag_synced),
    .change_power_mode(level_synced[0]),
    .power_domain_clk_0(pd_clk_0),
    .power_domain_clk_1(pd_clk_1)
);

wire pmu_changer;
wire [7:0] pmu_busSpeed;
//clkA should be PMU clock, clkB should be clock of controlling component
BusAck_CrossDomain #(
    .size(4)
    ) level_sync(
	.clkA(pd_clk_1),
	.rstA(reset),
	.FlagIn_clkA(pmu_changer),
	//.Busy_clkA(),
	.clkB(clock),
	.rstB(reset),
	.FlagOut_clkB(level_flag_synced),
	.BusIn({cpu_dout[5:4],cpu_dout[1:0]}),
	.BusOut(level_synced)
);

assign power_mode_flag_synced = level_synced[3] & level_flag_synced;

wire [7:0] cpu_dout_synced_0;
wire txValid_synced_0;
wire txValidBusy;
BusAck_CrossDomain #(
    .size(8)
    ) cpu_dout_PD_2_PD_1(
	.clkA(pd_clk_1),
	.rstA(reset),
	.FlagIn_clkA(txValid),
	.Busy_clkA(txValidBusy),
	.clkB(pd_clk_0),
	.rstB(reset),
	.FlagOut_clkB(txValid_synced_0),
	.BusIn(cpu_dout),
	.BusOut(cpu_dout_synced_0)
);

wire rxValid_synced_0;
FlagAck_CrossDomain rxValid_PD_1_PD_2(
	.clkA(pd_clk_0),
	.rstA(reset),
	.FlagIn_clkA(rxValid),
	//.Busy_clkA(),
	.clkB(pd_clk_1),
	.rstB(reset),
	.FlagOut_clkB(rxValid_synced_0)
);


//---------------------------------------------------------------------------------------
// End of auto generated components PMU + synchronizers
//---------------------------------------------------------------------------------------

// reg [15:0] uartbaud;
reg rxfull, scpu_io;
reg spifull;
reg [7:0] p1reg, p1dir, p2reg, p2dir, io_dout;
reg [3:0] intr_ena;

// reset button
always @ (posedge pd_clk_1) 
begin
	if (reset_state) begin
		reset <= 1'b1;
		reset_state <= 1'b0;
	end
	else begin
		reset <= 1'b0;
	end
end

//---------------------------------------------------------------------------------------
// module implementation
// light8080 CPU instance
light8080 cpu
(
	.clk(pd_clk_1),
	.reset(reset),
	.addr_out(cpu_addr),
	.vma(/* nu */),
	.io(cpu_io),
	.rd(cpu_rd),
	.wr(cpu_wr),
	.fetch(/* nu */),
	.data_in(cpu_din),
	.data_out(cpu_dout),
	.inta(cpu_inta),
	.inte(cpu_inte),
	.halt(/* nu */),
	.intr(cpu_intr)
);

// cpu data input selection
assign cpu_din = (cpu_inta) ? intr_dout : (scpu_io) ? io_dout : ram_dout;

//new RAM from hex
membram #(8, "firmware/test.vhex", (1<<6)-1) rom
(
	.clk		(pd_clk_1),
	.reset		(reset),
	.data_out	(ram_dout),
	.data_in	(cpu_dout),
	.cs			(1'b1),
	.rd			(~cpu_wr & ~cpu_io),
	.wr			(cpu_wr & ~cpu_io),
	.addr		(cpu_addr[7:0])
);

// io space write registers
always @ (posedge reset or posedge pd_clk_1)
begin
	if (reset)
	begin
		// uartbaud <= 16'd12;
		rxfull <= 1'b0;
		spifull <= 1'b0;
		p1reg <= 8'b0;
		p1dir <= 8'b0;
		p2reg <= 8'b0;
		p2dir <= 8'b0;
		intr_ena <= 4'b0;
	end
	else
	begin
		// io space registers
		if (cpu_wr && cpu_io)
		begin
			// if (cpu_addr[7:0] == `UBAUDL_REG)	uartbaud[7:0] <= cpu_dout;
			// if (cpu_addr[7:0] == `UBAUDH_REG)	uartbaud[15:8] <= cpu_dout;
			// if (cpu_addr[7:0] == `P1_DATA_REG)	p1reg <= cpu_dout;
			// if (cpu_addr[7:0] == `P1_DIR_REG)	p1dir <= cpu_dout;
			// if (cpu_addr[7:0] == `P2_DATA_REG)	p2reg <= cpu_dout;
			// if (cpu_addr[7:0] == `P2_DIR_REG)	p2dir <= cpu_dout;
			if (cpu_addr[7:0] == `INTR_EN_REG)	intr_ena <= cpu_dout[3:0];
		end

		// receiver full flag
		if (rxValid_synced_0 && !rxfull)
			rxfull <= 1'b1;
		else if (cpu_rd && cpu_io && (cpu_addr[7:0] == `UDATA_REG) && rxfull)
			rxfull <= 1'b0;
	end
end
// uart transmit write pulse
assign txValid = cpu_wr & cpu_io & (cpu_addr[7:0] == `UDATA_REG);
//assign spiValid = cpu_wr & cpu_io & (cpu_addr[7:0] == `SPI_TX_REG);
// pmu trans
assign pmu_changer = cpu_wr & cpu_io & (cpu_addr[7:0] == `PMU_REG);

// io space read registers
always @ (posedge reset or posedge pd_clk_1)
begin
	if (reset)
	begin
		io_dout <= 8'b0;
	end
	else
	begin
		// io space read registers
		if (cpu_io && (cpu_addr[7:0] == `UDATA_REG))
			io_dout <= rxData;
		else if (cpu_io && (cpu_addr[7:0] == `USTAT_REG))
			io_dout <= {3'b0, rxfull, 3'b0, txValidBusy | txBusy};
//		else if (cpu_io && (cpu_addr[7:0] == `SPI_RX_REG))
//			io_dout <= spiRxdata;

//		else if (cpu_io && (cpu_addr[7:0] == `P1_DATA_REG))
//			io_dout <= p1dio;
//		else if (cpu_io && (cpu_addr[7:0] == `P2_DATA_REG))
//			io_dout <= p2dio;

		// sampled io control to select cpu data input
		scpu_io <= cpu_io;
	end
end

// interrupt controller
intr_ctrl intrc
(
	.clock(pd_clk_1),
	.reset(reset),
	.ext_intr(extint),
	.cpu_intr(cpu_intr),
	.cpu_inte(cpu_inte),
	.cpu_inta(cpu_inta),
	.cpu_rd(cpu_rd),
	.cpu_inst(intr_dout),
	.intr_ena(intr_ena)
);

//assign txBusy = ~txDone;

uart #(
		.baud_rate(9600),                 // The baud rate in kilobits/s
		.sys_clk_freq(12000000)           // The master clock frequency
)
RS232(
	.clk(pd_clk_0),
	.rst(reset),
	.rx(rxd),
	.tx(txd),
	.transmit(txValid_synced_0),
	.tx_byte(cpu_dout_synced_0),
	.rx_byte(rxData),
	.received(rxValid),
	.is_transmitting(txBusy)
);

// spi_master spi_master(
//   .rstb(~reset),
//   .clk(clock),
//   .mlb(1'b1), // MSB first???
//   .start(spiValid),
//   .tdat(cpu_dout),
//   .cdiv(3), // :32
//   .din(din),
//   .ss(ss),
//   .sck(sck),
//   .dout(dout),
//   .done(spiFull),
//   .rdata(spiRxData)
// );

// digital IO ports
// port 1
// assign p1dio[0] = p1dir[0] ? p1reg[0] : 1'bz;
// assign p1dio[1] = p1dir[1] ? p1reg[1] : 1'bz;
// assign p1dio[2] = p1dir[2] ? p1reg[2] : 1'bz;
// assign p1dio[3] = p1dir[3] ? p1reg[3] : 1'bz;
// assign p1dio[4] = p1dir[4] ? p1reg[4] : 1'bz;
// assign p1dio[5] = p1dir[5] ? p1reg[5] : 1'bz;
// assign p1dio[6] = p1dir[6] ? p1reg[6] : 1'bz;
// assign p1dio[7] = p1dir[7] ? p1reg[7] : 1'bz;
// port 2
// assign p2dio[0] = p2dir[0] ? p2reg[0] : 1'bz;
// assign p2dio[1] = p2dir[1] ? p2reg[1] : 1'bz;
// assign p2dio[2] = p2dir[2] ? p2reg[2] : 1'bz;
// assign p2dio[3] = p2dir[3] ? p2reg[3] : 1'bz;
// assign p2dio[4] = p2dir[4] ? p2reg[4] : 1'bz;
// assign p2dio[5] = p2dir[5] ? p2reg[5] : 1'bz;
// assign p2dio[6] = p2dir[6] ? p2reg[6] : 1'bz;
// assign p2dio[7] = p2dir[7] ? p2reg[7] : 1'bz;

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------