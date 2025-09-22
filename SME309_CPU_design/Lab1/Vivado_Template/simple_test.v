`timescale 1ns / 1ps

// 简化测试：只测试control模块的addr输出
module simple_test();

reg clk;
reg pause, speedup, speeddown;
wire [7:0] addr;

// 只实例化control模块
control dut(
    .clk(clk),
    .pause(pause),
    .speedup(speedup),
    .speeddown(speeddown),
    .addr(addr)
);

// 时钟生成
initial begin
    clk = 0;
    forever #50 clk = ~clk;
end

// 简单的输入激励
initial begin
    pause = 0;
    speedup = 0;
    speeddown = 0;

    // 等待几个时钟周期后检查addr
    #500;
    $display("At 500ns: addr = %h", addr);
    #1000;
    $display("At 1500ns: addr = %h", addr);
    #10000;
    $display("At 11500ns: addr = %h", addr);
    #100000;
    $display("At 111500ns: addr = %h", addr);

    $finish;
end

// 监控addr的变化
always @(addr) begin
    $display("Time %0t: addr changed to %h", $time, addr);
end

initial begin
    $dumpfile("simple_test.vcd");
    $dumpvars(0, simple_test);
end

endmodule