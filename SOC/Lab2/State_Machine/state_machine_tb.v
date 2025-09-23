`timescale 1ns/1ps
module state_tb;

    reg clk, reset, run, halt, cont;
    wire [2:0] cs;

    // 被测模块实例，确保工程中有名为 state 的模块并带有相应端口
    state state0 (
        .clk(clk),
        .reset(reset),
        .run(run),
        .cont(cont),
        .halt(halt),
        .cs(cs)
    );

    initial begin
        clk = 0;
        forever
            #50 clk = ~clk;
    end

    initial begin
        reset = 0; run = 0; halt = 0; cont = 0;
        #100 reset = 1; run = 1;
        #100 run = 0;
        #200 cont = 1;
        #100 cont = 0;
        #600 halt = 1;
        #100 halt = 0;
        #1000 $finish;
    end

endmodule