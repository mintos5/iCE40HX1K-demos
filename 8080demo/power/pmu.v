module power_manager(
    input clk,                  // The master clock for this module
    input pll_clk,
    input reset,                  // Synchronous reset
    input change,             // Assert to begin change of system
    input [7:0] change_vector,        // Byte to transmit
    output wire clock1,   // Low when receive line is idle.
    output wire clock2, // Low when transmit line is idle.
    output wire clock3
);

`define SET_PLL             3'b000      // used for setting PLL
`define SET_CLK             3'b001       // set default 12 mhz clock
`define SET_FR1             3'b010       // set freq1
`define SET_FR2             3'b011       // set freq2
`define SET_FR3             3'b100       // set freq3

reg clock1_reg = 1'b0;
reg clock2_reg = 1'b0;
reg clock3_reg = 1'b0;


reg [2:0] clock1_setter = 3'b001;
// reg pll_clock1_en = 1'b0;
// reg default_clock1_en = 1'b1;
// reg clock1_fr1 = 1'b0;
// reg clock1_fr2 = 1'b1;
// reg clock1_fr3 = 1'b0;


reg [2:0] clock2_setter = 3'b011;
// reg pll_clock2_en = 1'b1;
// reg default_clock2_en = 1'b0;
// reg clock2_fr1 = 1'b0;
// reg clock2_fr2 = 1'b0;
// reg clock2_fr3 = 1'b1;


reg [2:0] clock3_setter = 3'b000;
// reg pll_clock3_en = 1'b0;
// reg default_clock3_en = 1'b0;
// reg clock3_fr1 = 1'b1;
// reg clock3_fr2 = 1'b0;
// reg clock3_fr3 = 1'b0;

reg [20:0] clock_div1 = 21'h16e360;
reg [20:0] clock_div2 = 21'h5000;
reg [20:0] clock_div3 = 21'h10;


//todo rewrite it to reset portion of code

//todo urobit wake up
assign clock1 = (clock1_setter == `SET_PLL) ? pll_clk : (clock1_setter == `SET_CLK) ? clk : clock1_reg;
assign clock2 = (clock2_setter == `SET_PLL) ? pll_clk : (clock2_setter == `SET_CLK) ? clk : clock2_reg;
assign clock3 = (clock3_setter == `SET_PLL) ? pll_clk : (clock3_setter == `SET_CLK) ? clk : clock3_reg;


always @ (posedge clk) begin 
    if (reset) begin
        //dividers for frequency
        clock_div1 <= 21'h16e360;
        clock_div2 <= 21'h800;
        clock_div3 = 21'h10;
    end
    else begin
        //FREQ1
        if (clock_div1) begin
            clock_div1 <= clock_div1 - 21'd1;
        end
        else begin
            clock_div1 <= 21'h16e360;
            //clock1
            if (clock1_setter == `SET_FR1) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_setter == `SET_FR1) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_setter == `SET_FR1) begin
                if (!clock3_reg) begin
                    clock3_reg <= 1'b1;
                end
                else begin
                    clock3_reg <= 1'b0;
                end
            end
        end


        //FREQ2
        if (clock_div2) begin
            clock_div2 <= clock_div2 - 21'd1;
        end
        else begin
            clock_div2 <= 21'h5000;
            //clock1
            if (clock1_setter == `SET_FR2) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_setter == `SET_FR2) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_setter == `SET_FR2) begin
                if (!clock3_reg) begin
                    clock3_reg <= 1'b1;
                end
                else begin
                    clock3_reg <= 1'b0;
                end
            end
        end

        //FREQ3
        if (clock_div3) begin
            clock_div3 <= clock_div3 - 21'd1;
        end
        else begin
            clock_div3 <= 21'h10;
            //clock1
            if (clock1_setter == `SET_FR3) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_setter == `SET_FR3) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_setter == `SET_FR3) begin
                if (!clock3_reg) begin
                    clock3_reg <= 1'b1;
                end
                else begin
                    clock3_reg <= 1'b0;
                end
            end
        end

        //Controller part
        if (change) begin
            //Change clock1
            if (change_vector[7]) begin
                clock1_setter <= change_vector[2:0];
            end
            //Change clock2
            if (change_vector[6]) begin
                clock2_setter <= change_vector[2:0];
            end
            //Change clock3
            if (change_vector[5]) begin
                clock3_setter <= change_vector[2:0];
            end
        end

    end
end



endmodule