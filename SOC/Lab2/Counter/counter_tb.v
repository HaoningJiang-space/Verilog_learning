`timescale 1ns/1ps

module counter_tb;
    reg clk = 0;
    reg rst_n;
    reg en;
    reg dir;
    reg [7:0] load;
    reg ld;
    wire [7:0] q;

    // Instantiate
    counter #(.WIDTH(8)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .dir(dir),
        .load(load),
        .ld(ld),
        .q(q)
    );

    // clock
    always #5 clk = ~clk; // 100 MHz -> period 10 ns

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        // reset
        rst_n = 0; en = 0; dir = 1; load = 8'hAA; ld = 0;
        #20;
        rst_n = 1;

        // count up
        en = 1; dir = 1;
        #200;

        // load a value
        ld = 1; load = 8'h10;
        #10; ld = 0;

        // count down
        dir = 0;
        #100;

        $finish;
    end
endmodule