
module power_manager(
    input clk,                  // The master clock for this module
    input reset,                  // Synchronous reset
    input change_level_flag,
    input [2:0] change_level,        // First 1 bits select power_domain
    input change_power_mode_flag,
    input change_power_mode,        // Signal to change power_mode
    output wire power_domain_clk_0,
    output wire power_domain_clk_1
);
// wire and pll module
wire pll_clk;

SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"),
                  .PLLOUT_SELECT("GENCLK"),
                  .DIVR(4'b0000),
                  .DIVF(7'b0111111),
                  .DIVQ(3'b100),
                  .FILTER_RANGE(3'b001)
                 ) uut (
                         .REFERENCECLK(clk),
                         .PLLOUTCORE(pll_clk),
                         //.PLLOUTGLOBAL(clk),
                         // .LOCK(D5),
                         .RESETB(1'b1),
                         .BYPASS(1'b0)
                        );


// reg and warmboot module for reconfiguration
reg [2:0] reconf_setter = 2'b00;
reg reconf_boot = 1'b0;

SB_WARMBOOT  my_warmboot_i  (
    .BOOT (reconf_boot),
    .S1 (reconf_setter[1]),
    .S0 (reconf_setter[0])
);


// Generated levels
`define SET_FR0 2'b00      // use for setting DIFF_LEVEL(2) 48.0
`define SET_FR1 2'b01      // use for setting NORMAL 12.0
`define SET_FR2 2'b10      // use for setting DIFF_LEVEL(1) 0.0012
`define SET_FR3 2'b11      // use for setting OFF 0


// Inner registers for divider
reg counter_reg_2 = 1'b0;

reg [12:0] counter_2 = 13'h0;


// Power domains registers and assigns
reg [1:0] power_domain_0_setter = 2'b01;
reg [1:0] power_domain_1_setter = 2'b10;

assign power_domain_clk_0 = (power_domain_0_setter == `SET_FR1) ? clk : 1'b0;
assign power_domain_clk_1 = (power_domain_1_setter == `SET_FR1) ? clk : (power_domain_1_setter == `SET_FR2) ? counter_reg_2 : (power_domain_1_setter == `SET_FR0) ? pll_clk : 1'b0;


// Synchronous sequential logic
always @ (posedge clk) begin
    if (reset) begin
        counter_2 <= 13'h0;
        counter_reg_2 <= 1'b0;
        reconf_setter <= 2'b00;
        reconf_boot <= 1'b0;
        power_domain_0_setter = 2'b01;
        power_domain_1_setter = 2'b10;
    end
    else begin

        if (counter_2) begin
            counter_2 <= counter_2 - 13'd1;
        end
        else begin
            counter_2 <= 13'd4999;
            counter_reg_2 <= !counter_reg_2;
        end

        // Controllers
        if (change_level_flag) begin
            if (change_level[2:2] == 1'b0) begin
                power_domain_0_setter <= change_level[1:0];
            end
            if (change_level[2:2] == 1'b1) begin
                power_domain_1_setter <= change_level[1:0];
            end
        end
        if (change_power_mode_flag) begin
            if (change_power_mode == 1'b0) begin
                power_domain_0_setter <= 2'b01;
                power_domain_1_setter <= 2'b10;
            end
            if (change_power_mode == 1'b1) begin
                reconf_boot <= 1'b1;
                reconf_setter <= 2'b01;
            end
        end

    end
end

endmodule
