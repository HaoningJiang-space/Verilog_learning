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

    // 先让系统运行短时间，观察地址递增
    #2000;   // 2μs，应该能看到10次地址变化

    // 测试暂停功能
    pause = 1;
    #500;    // 暂停0.5μs
    pause = 0;

    // 继续运行
    #2000;   // 再运行2μs

    // 测试加速功能
    speedup = 1;
    #200;    // 200ns
    speedup = 0;

    // 观察加速后的效果
    #2000;   // 2μs

    $finish;
end
        
initial begin
    $dumpfile("testbench.wave");
    $dumpvars;
    $display("save to testbench.wave");
end 
    
endmodule
