`timescale 1ns/1ps

module counter_4bit_tb;
    reg clk;
    reg reset;
    wire [3:0] count;
    
    // 实例化计数器
    counter_4bit uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期
    end
    
    // 测试序列
    initial begin
        // 初始化输入并应用复位
        reset = 1;
        #10;
        reset = 0;
        
        // 监控计数器从0计数到15然后溢出回0
        $display("开始计数测试：");
        
        // 等待计数器完成一个完整周期加一点
        #320;
        
        // 结束仿真
        $finish;
    end
    
    // 监控输出
    initial begin
        $monitor("Time = %0t, Count = %b (%d)", $time, count, count);
    end
endmodule