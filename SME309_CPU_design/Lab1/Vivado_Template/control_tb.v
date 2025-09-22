`timescale 1ns / 1ps

module control_tb();

reg clk;
reg pause;
reg speedup;
reg speeddown;
wire [7:0] addr;
wire [31:0] data;
wire [7:0] anode;
wire [6:0] cathode;
wire dp;
wire [7:0] led;

top dut(clk, pause, speedup, speeddown, anode, cathode, dp, led);

initial begin
    clk = 0;
    forever #50 clk=~clk;
end

initial begin
    pause = 0; speedup = 0; speeddown = 0;
    #1650 pause = 1;
    #3200 pause = 0;
    #500 speedup = 1;
    #1600 pause = 1;
    #1600 speedup = 0; pause = 0;
    #3200 $finish;
end
        
initial begin
    $dumpfile("testbench.wave");
    $dumpvars;
    $display("save to testbench.wave");
end 
    
endmodule
