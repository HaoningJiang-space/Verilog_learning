`timescale 1ns / 1ps

// Testbench for state_machine
// ========================================

module state_machine_tb;

    // Inputs
    reg clk;
    reg reset;
    reg nextstate;
    reg jumpstate;

    // Outputs
    wire [2:0] state;

    // Instantiate the Unit Under Test (UUT)
    state_machine uut (
        .clk(clk), 
        .reset(reset), 
        .nextstate(nextstate), 
        .jumpstate(jumpstate), 
        .state(state)
    );

    initial begin 
        clk = 0;
        forever #25 clk = ~clk; 
    end

    initial begin
        // Initialize Inputs
        reset = 1;
        nextstate = 0;
        jumpstate = 0;

        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        
        // Add stimulus here
        #50; nextstate = 1; // S0 -> S1
        #50; nextstate = 0; // Hold S1
        #50; nextstate = 1; // S1 -> S3
        #50; nextstate = 0; // Hold S3
        #50; jumpstate = 1; // S3 -> S5
        #50; jumpstate = 0; // Hold S5
        #50; nextstate = 1; // S5 -> S0
        #50; nextstate = 0; // Hold S0

        #50; jumpstate = 1; // S0 -> S2
        #50; jumpstate = 0; // Hold S2
        #50; nextstate = 1; // S2 -> S4
        #50; nextstate = 0; // Hold S4
        #50; nextstate = 1; // S4 -> S5
        #50; nextstate = 0; // Hold S5

        #50; nextstate = 1; jumpstate = 1; // S5 -> S0 (nextstate has priority)
        #50; nextstate = 0; jumpstate = 0; // Hold S

        #50; $finish;
    end
    
endmodule
