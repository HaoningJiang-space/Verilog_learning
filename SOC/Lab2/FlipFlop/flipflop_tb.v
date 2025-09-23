// TestBench of flipflop.v

`timescale 1ns / 1ps

module flipflop_tb;

    reg D;
    reg CLK;
    wire Q;

    // Instantiate the flip-flop
    flipflop uut (
        .D(D),
        .CLK(CLK),
        .Q(Q)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;  // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
        // Test case 1: D = 0, CLK = 0
        D = 0;
        #10;  // Wait for 10 time units

        // Test case 2: D = 0, CLK = 1
        D = 0;
        #10;

        // Test case 3: D = 1, CLK = 0
        D = 1;
        #10;

        // Test case 4: D = 1, CLK = 1
        D = 1;
        #10;

        // End simulation
        $finish;
    end

endmodule
