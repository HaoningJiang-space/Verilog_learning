`timescale 1ns / 1ps

module control_tb();

reg clk;
reg pause;
reg speedup;
reg speeddown;
wire [7:0] anode;
wire [6:0] cathode;
wire dp;
wire [7:0] led;


wire [7:0] addr;
wire [31:0] data;

top dut(
    .btn_p(pause),
    .btn_spdup(speedup),
    .btn_spddn(speeddown),
    .clk(clk),
    .anode(anode),
    .cathode(cathode),
    .dp(dp),
    .led(led)
);

// 连接内部信号用于观察
assign addr = dut.addr;
assign data = dut.data;

initial begin
    clk = 0;
    forever #50 clk=~clk;
end

initial begin
    pause = 0; speedup = 0; speeddown = 0;
    $display("Testbench started at time %0t", $time);

    $display("Time %0t: Normal speed test - should see addr change every 400ns", $time);
    #2000;  

    $display("Time %0t: Testing speeddown (16 clocks=1600ns per change)", $time);
    speeddown = 1;
    #8000; 

    $display("Time %0t: Back to normal speed", $time);
    speeddown = 0;
    #2000;  

    $display("Time %0t: Testing speedup (1 clock=100ns per change)", $time);
    speedup = 1;
    #1000; 

    $display("Time %0t: Back to normal speed", $time);
    speedup = 0;
    #2000;  

    $display("Time %0t: Testing pause", $time);
    pause = 1;
    #1000; 

    $display("Time %0t: Resume from pause", $time);
    pause = 0;
    #2000;  

    $display("Time %0t: Finishing simulation", $time);
    $finish;
end
        
initial begin
    $dumpfile("testbench.wave");
    $dumpvars;
    $display("save to testbench.wave");
end 
    
endmodule
