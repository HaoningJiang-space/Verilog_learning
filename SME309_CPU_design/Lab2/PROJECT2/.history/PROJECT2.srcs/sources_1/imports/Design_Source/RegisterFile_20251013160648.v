`timescale 1ns/1ps
module RegisterFile(
    input        CLK,
    input        WE3,
    input  [3:0] A1,
    input  [3:0] A2,
    input  [3:0] A3,
    input  [31:0] WD3,
    input  [31:0] R15,
    // 新增：用于寄存器移位量读取（Rs）
    input  [3:0] A4,
    output [31:0] RD1,
    output [31:0] RD2,
    output [31:0] RD4
);
    reg [31:0] RegBank[0:14];
    integer i;

    initial begin
        for (i=0;i<15;i=i+1) RegBank[i]=32'b0;
    end

    // synchronous write on rising edge; R15 (15) is not stored in RegBank
    always @(posedge CLK) begin
        if (WE3 && (A3 != 4'd15))
            RegBank[A3] <= WD3;
    end

    // asynchronous read; if address is 15, return external R15 (PC)
    assign RD1 = (A1 == 4'd15) ? R15 : RegBank[A1];
    assign RD2 = (A2 == 4'd15) ? R15 : RegBank[A2];
    assign RD4 = (A4 == 4'd15) ? R15 : RegBank[A4];
endmodule