`timescale 1ns/1ps
module Shifter(
    input  [1:0]  Sh,       // 00 LSL, 01 LSR, 10 ASR, 11 ROR
    input  [4:0]  Shamt5,
    input         ShAmtFromReg,   // 新增：1=移位量来自寄存器
    input  [31:0] RsVal,          // 新增：寄存器移位量来源
    input  [31:0] ShIn,
    output [31:0] ShOut
);
    reg [31:0] r;
    wire [4:0] amt = ShAmtFromReg ? RsVal[4:0] : Shamt5;
    always @(*) begin
        case (Sh)
            2'b00: r = ShIn << amt;
            2'b01: r = ShIn >> amt;
            2'b10: r = $signed(ShIn) >>> amt;
            default: begin
                if (amt==0) r = ShIn;
                else        r = (ShIn >> amt) | (ShIn << (32 - amt));
            end
        endcase
    end
    assign ShOut = r;
endmodule
