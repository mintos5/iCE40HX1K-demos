module counter(
	input clk,
	output outPin,
    output [4:0] counter_out
);

reg [25:0] counter = 26'h3938700;
reg outBit = 1'b0;

always @ (posedge clk) begin 
	if (counter) begin
        counter <= counter - 63'd1;
    end
    else begin
    	counter <= 26'h3938700;
    	if (!outBit) begin
            outBit <= 1'b1;
        end
        else begin
            outBit <= 1'b0;
        end
    end
end

assign outPin = outBit;
assign  counter_out = counter[25:21];

endmodule