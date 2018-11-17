module BusAck_CrossDomain(
    input clkA,
    input FlagIn_clkA,
    output Busy_clkA,
    input clkB,
    output FlagOut_clkB,
    input [7:0] BusIn,
    output[7:0] BusOut
);

reg FlagToggle_clkA = 1'b0;
reg [7:0] BusReg = 8'd0;
always @(posedge clkA) begin
	FlagToggle_clkA <= FlagToggle_clkA ^ (FlagIn_clkA & ~Busy_clkA);
	if (FlagIn_clkA & ~Busy_clkA) begin
		BusReg <= BusIn;
	end
end

reg [2:0] SyncA_clkB = 3'b000;
always @(posedge clkB) SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};

reg [1:0] SyncB_clkA = 2'b00;
always @(posedge clkA) begin
	SyncB_clkA <= {SyncB_clkA[0], SyncA_clkB[2]};
end

assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);
assign Busy_clkA = FlagToggle_clkA ^ SyncB_clkA[1];
assign BusOut = BusReg;
endmodule