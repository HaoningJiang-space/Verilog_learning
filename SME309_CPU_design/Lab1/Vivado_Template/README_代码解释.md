# Verilog代码详细解释文档

本文档详细解释了指令ROM和数据ROM显示系统的Verilog实现。

## 系统概述

这个系统实现了一个简单的存储器显示系统，包含：
- 指令存储器(Instruction ROM) - 128个32位字
- 数据存储器(Data ROM) - 128个32位字
- 控制单元 - 管理地址生成和显示速度
- 七段数码管显示 - 显示存储器内容
- LED显示 - 显示当前地址

## 模块详细解释

### 1. top.v - 顶层模块

```verilog
module top(
    input btn_p,                // 暂停按钮
    input btn_spdup,            // 加速按钮
    input btn_spddn,            // 减速按钮
    input clk,                  // 时钟信号 (100MHz)
    output [7:0] anode,         // 七段数码管阳极
    output [6:0] cathode,       // 七段数码管阴极
    output dp,                  // 小数点
    output [7:0] led            // LED显示
);
```

**关键概念解释：**

- **模块定义**: `module`关键字定义一个模块，类似于C语言中的函数
- **输入输出端口**: `input`和`output`定义模块的接口
- **线网声明**: `wire`用于连接不同模块之间的信号

**连接关系：**
```verilog
wire [7:0] addr;    // 8位地址线
wire [31:0] data;   // 32位数据线

control ctrl(clk, btn_p, btn_spdup, btn_spddn, addr);
mem memory(clk, addr, data);
Seven_Seg ss(clk, data, anode, dp, cathode);
assign led = addr;  // LED直接显示地址
```

### 2. control.v - 控制模块

这是系统的核心控制逻辑，负责：
- 生成存储器地址
- 管理显示速度
- 处理按钮输入

**状态机设计：**
```verilog
parameter NORMAL = 2'b00;   // 正常速度: 1字/秒
parameter HIGH   = 2'b01;   // 高速: 4字/秒
parameter LOW    = 2'b10;   // 低速: 0.25字/秒
```

**按钮边沿检测：**
```verilog
// 存储上一个时钟周期的按钮状态
reg pause_prev, speedup_prev, speeddown_prev;

// 检测按钮按下的瞬间（上升沿）
assign pause_edge = pause & ~pause_prev;
assign speedup_edge = speedup & ~speedup_prev;
assign speeddown_edge = speeddown & ~speeddown_prev;
```

**为什么需要边沿检测？**
- 按钮按下时会保持高电平很多个时钟周期
- 我们只想在按钮刚按下的那一瞬间触发动作
- 边沿检测确保每次按下只触发一次

**时钟分频器：**
```verilog
// 根据速度状态设置计数阈值
always @(*) begin
    case (speed_state)
        NORMAL: speed_threshold = 100_000_000;     // 1秒 @100MHz
        HIGH:   speed_threshold = 25_000_000;      // 0.25秒 @100MHz
        LOW:    speed_threshold = 400_000_000;     // 4秒 @100MHz
    endcase
end
```

**地址生成逻辑：**
```verilog
// 8位地址的组成：
// addr[7] = 存储器选择位 (0=指令存储器, 1=数据存储器)
// addr[6:0] = 实际地址 (0-127)

always @(*) begin
    addr = {mem_select, mem_addr};
end
```

### 3. mem.v - 存储器模块

**存储器结构：**
```verilog
reg [31:0] instr_mem [0:127];  // 指令存储器数组
reg [31:0] data_mem [0:127];   // 数据存储器数组
```

**重要Verilog概念：**
- `reg [31:0]` - 32位寄存器类型
- `[0:127]` - 数组大小，128个元素
- `reg`类型可以在`always`块中赋值

**存储器访问逻辑：**
```verilog
always @(posedge clk) begin
    if (addr[7] == 0) begin
        // 访问指令存储器
        data <= instr_mem[addr[6:0]];
    end else begin
        // 访问数据存储器
        data <= data_mem[addr[6:0]];
    end
end
```

**为什么用时钟边沿？**
- `@(posedge clk)` 表示在时钟上升沿触发
- 这模拟了真实存储器的同步读取特性
- 确保数据在稳定的时序下更新

**存储器初始化：**
```verilog
initial begin
    // 初始化指令存储器
    instr_mem[0] = 32'h12345678;
    instr_mem[1] = 32'h9ABCDEF0;
    // ... 更多初始化

    // 用循环初始化剩余位置
    integer i;
    for (i = 16; i < 128; i = i + 1) begin
        instr_mem[i] = i * 32'h01010101;
    end
end
```

### 4. Seven_Seg.v - 七段数码管显示

七段数码管显示是最复杂的模块，需要理解以下概念：

**时分复用显示：**
- 8个数码管共享相同的段线（cathode）
- 通过快速切换不同数码管的使能信号（anode）
- 利用人眼的视觉暂留效应看到完整显示

**刷新计数器：**
```verilog
reg [19:0] refresh_counter;         // 20位计数器
wire [2:0] digit_select;            // 3位数码管选择信号

assign digit_select = refresh_counter[19:17];  // 使用高3位
```

**为什么用高3位？**
- 低位变化太快，会造成闪烁
- 高位变化较慢，提供合适的刷新速度
- 3位可以选择8个数码管（2³ = 8）

**数字提取逻辑：**
```verilog
always @(*) begin
    case (digit_select)
        3'b000: digit_value = data[3:0];    // 最低4位
        3'b001: digit_value = data[7:4];    // 次低4位
        3'b010: digit_value = data[11:8];   // ...
        3'b011: digit_value = data[15:12];
        3'b100: digit_value = data[19:16];
        3'b101: digit_value = data[23:20];
        3'b110: digit_value = data[27:24];
        3'b111: digit_value = data[31:28];  // 最高4位
    endcase
end
```

**阳极控制（数码管选择）：**
```verilog
// 阳极低电平有效，一次只能点亮一个数码管
always @(*) begin
    case (digit_select)
        3'b000: anode_reg = 8'b11111110; // 只有最右边的数码管亮
        3'b001: anode_reg = 8'b11111101; // 只有右边第二个亮
        // ... 以此类推
    endcase
end
```

**七段译码器：**
```verilog
always @(*) begin
    case (digit_value)
        4'h0: cathode_reg = 7'b1000000; // 显示0
        4'h1: cathode_reg = 7'b1111001; // 显示1
        // ...
        4'hF: cathode_reg = 7'b0001110; // 显示F
    endcase
end
```

**七段数码管段位对应：**
```
  a
f   b
  g
e   c
  d
```
cathode[6:0] = {g,f,e,d,c,b,a}

## 重要Verilog概念总结

### 1. always块的类型

**组合逻辑（always @(*)**：**
```verilog
always @(*) begin
    // 输出立即随输入变化
    y = a & b;
end
```

**时序逻辑（always @(posedge clk)**：**
```verilog
always @(posedge clk) begin
    // 在时钟上升沿更新
    q <= d;
end
```

### 2. 赋值操作符

- **阻塞赋值（=）**: 立即执行，用于组合逻辑
- **非阻塞赋值（<=）**: 在时钟边沿同时执行，用于时序逻辑

### 3. 数据类型

- **wire**: 用于连接，不能存储值
- **reg**: 可以存储值，用在always块中

### 4. 位操作

```verilog
wire [7:0] addr = {mem_select, mem_addr};  // 位拼接
wire [6:0] low_addr = addr[6:0];           // 位选择
```

## 系统工作流程

1. **启动**: 系统从指令存储器地址0开始
2. **地址生成**: control模块根据速度设置生成地址
3. **存储器访问**: mem模块根据地址读取数据
4. **显示更新**: Seven_Seg模块显示当前数据，LED显示地址
5. **地址递增**: 达到127后切换到另一个存储器
6. **循环显示**: 指令存储器→数据存储器→指令存储器...

## 按钮功能

- **btn_p**: 暂停/恢复显示
- **btn_spdup**: 加速显示（正常→高速→正常）
- **btn_spddn**: 减速显示（正常→低速→正常）

这个设计很好地展示了数字系统设计的基本概念：状态机、存储器、显示控制和人机交互。