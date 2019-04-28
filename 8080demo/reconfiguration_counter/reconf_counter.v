`include "counter.v"
module reconf_counter 
(
	input clock,
    output led1, 
    output led2,
    output led3,
    output led4,
    output led5
);
//---------------------------------------------------------------------------------------

wire [4:0] counter_led;

assign {led5, led4, led3, led2, led1} = counter_led;


wire counter1;

counter c1 (
    .clk(clock),
    .outPin(counter1),
    .counter_out(counter_led)
);

SB_WARMBOOT  my_warmboot_i  (
    .BOOT (counter1),
    .S1 (1'b0),
    .S0 (1'b0)
);

endmodule