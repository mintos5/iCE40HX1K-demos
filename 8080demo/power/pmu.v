module power_manager(
    input clk,                  // The master clock for this module
    input pll_clk,
    input reset,                  // Synchronous reset
    // input change,             // Assert to begin change of system
    // input [7:0] change_vector,        // Byte to transmit
    output wire clock1,   // Low when receive line is idle.
    output wire clock2, // Low when transmit line is idle.
    output wire clock3
);

reg clock1_reg = 1'b0;
reg clock2_reg = 1'b0;
reg clock3_reg = 1'b0;

reg pll_clock1_en = 1'b0;
reg default_clock1_en = 1'b1;
reg clock1_fr1 = 1'b0;
reg clock1_fr2 = 1'b1;
reg clock1_fr3 = 1'b0;

reg pll_clock2_en = 1'b1;
reg default_clock2_en = 1'b0;
reg clock2_fr1 = 1'b0;
reg clock2_fr2 = 1'b0;
reg clock2_fr3 = 1'b1;

reg pll_clock3_en = 1'b0;
reg default_clock3_en = 1'b0;
reg clock3_fr1 = 1'b1;
reg clock3_fr2 = 1'b0;
reg clock3_fr3 = 1'b0;

reg [20:0] clock_div1 = 21'h16e360;
reg [20:0] clock_div2 = 21'h5000;
reg [20:0] clock_div3 = 21'h10;

reg [23:0] seconds_counter = 24'd12000000;
reg [7:0] timer = 8'd20;


//todo optimize freq picker

//todo urobit wake up
assign clock1 = (pll_clock1_en) ? pll_clk : (default_clock1_en) ? clk : clock2_reg;
assign clock2 = (pll_clock2_en) ? pll_clk : (default_clock2_en) ? clk : clock2_reg;
assign clock3 = (pll_clock3_en) ? pll_clk : (default_clock3_en) ? clk : clock3_reg;


always @ (posedge clk) 
begin 
    if (reset) begin
        seconds_counter <= 24'd12000000;
        timer <= 8'd20;
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
            if (clock1_fr1) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_fr1) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_fr1) begin
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
            if (clock1_fr2) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_fr2) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_fr2) begin
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
            if (clock1_fr3) begin
                if (!clock1_reg) begin
                    clock1_reg <= 1'b1;
                end
                else begin
                    clock1_reg <= 1'b0;
                end
            end
            //clock2
            if (clock2_fr3) begin
                if (!clock2_reg) begin
                    clock2_reg <= 1'b1;
                end
                else begin
                    clock2_reg <= 1'b0;
                end
            end
            //clock3
            if (clock3_fr3) begin
                if (!clock3_reg) begin
                    clock3_reg <= 1'b1;
                end
                else begin
                    clock3_reg <= 1'b0;
                end
            end
        end

        //timer part of PMU
        if (seconds_counter) begin
            seconds_counter <= seconds_counter - 24'd1;
        end
        else begin
            seconds_counter <= 24'd12000000;

            if (timer) begin
                timer <= timer - 1'd1;
            end
            else begin
                timer <= 8'd20;


                //example of pll, def, divided
                if (pll_clock2_en) begin
                    pll_clock2_en <= 1'b0;
                end
                else begin
                    // if (default_clock2_en) begin
                    //     default_clock2_en <= 1'b0;
                    // end
                    // else begin
                    //     default_clock2_en <= 1'b1;
                    //     //pll_clock1_en <= 1'b1;
                    // end
                    pll_clock2_en <= 1'b1;
                end

                
                // ZMENA FREKVENCIE
                

                // if (clock2_fr1) begin
                //     clock2_fr1 <= 1'b0;
                //     clock2_fr2 <= 1'b1;
                // end
                // else begin
                //     clock2_fr2 <= 1'b0;
                //     clock2_fr1 <= 1'b1;
                // end




                // if (clock2_fr2) begin
                //     clock2_fr2 <= 1'b0;
                //     clock2_fr3 <= 1'b1;
                // end
                // else begin
                //     clock2_fr2 <= 1'b1;
                //     clock2_fr3 <= 1'b0;
                // end

                // if (default_clock3_en) begin
                //     default_clock3_en <= 1'b0;
                // end
                // else begin
                //     default_clock3_en <= 1'b1;
                // end
            end
        end
    end
end



endmodule