`include "l80soc.v"
`timescale 1us/1us

module tb_l80soc;

    initial begin
        $dumpfile("l80soc.vcd");
        $dumpvars;

        delay(90);
        test_rcvr(8'h55);
        delay(95000);
        //delay(70000000);
        $finish;
        //# 250E3 $finish;
        //# 1E6 $finish;
    end

    reg clk = 0;
    always #1 clk = !clk;

    input  port_a;
    input  port_b;
    input led1;
    input led2;
    input led3;
    input led4;
    input led5;
    reg rx;
    wire tx;

    localparam baud_rate = 9600;

        /* General shortcuts */
        localparam T = 1'b1;
        localparam F = 1'b0;

    l80soc t1 (
        .clock      (clk),
        .txd      (tx),
        .rxd      (rx),
        .led1       (led1),
        .led2       (led2),
        .led3       (led3),
        .led4       (led4),
        .led5       (led5)
    );

    task delay(input integer N); begin
        repeat(N) @(posedge clk);
    end endtask


    task test_rcvr (input reg[7:0] C); 
        integer i;
        reg [7:0] shift_reg;
    begin
        shift_reg = C;
        @(posedge clk)
            rx = F;                         // send start bit
            delay(12e6/baud_rate);
            
        for(i = 0; i<8; i = i + 1) begin    // send serial data LSB first
            rx = shift_reg[0];
            shift_reg = shift_reg >> 1;
            delay(12e6/baud_rate);
        end
        
            rx = T;                         // send stop bit
            delay(12e6/baud_rate);
        
    end endtask

endmodule