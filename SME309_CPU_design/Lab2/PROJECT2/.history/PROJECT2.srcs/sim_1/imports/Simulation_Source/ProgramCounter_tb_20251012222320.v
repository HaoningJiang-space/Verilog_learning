`timescale 1ns/1ps
`include "../Design_Source/ProgramCounter.v"

module ProgramCounter_tb_isolation;
  reg         CLK  = 0;
  reg         Reset= 1;
  reg         PCSrc= 0;
  reg  [31:0] Result = 32'h0;
  wire [31:0] PC;
  wire [31:0] PC_Plus_4;

  // 100MHz 时钟
  always #5 CLK = ~CLK;

  ProgramCounter dut (
    .CLK(CLK),
    .Reset(Reset),
    .PCSrc(PCSrc),
    .Result(Result),
    .PC(PC),
    .PC_Plus_4(PC_Plus_4)
  );

  initial begin
    // 释放复位
    #20 Reset = 0;

    // 连续3拍自增
    repeat(3) @(posedge CLK);
    if (PC !== 32'd12) $fatal(1, "PC auto-increment failed, PC=%0d", PC);

    // 分支跳转
    Result = 32'h0000_0020; PCSrc = 1;
    @(posedge CLK);
    if (PC !== 32'h20) $fatal(1, "PC branch failed, PC=%h", PC);

    // 恢复自增
    PCSrc = 0;
    @(posedge CLK);
    if (PC !== 32'h24) $fatal(1, "PC resume inc failed, PC=%h", PC);

    $display("ProgramCounter TB passed.");
    #20 $finish;
  end
endmodule
