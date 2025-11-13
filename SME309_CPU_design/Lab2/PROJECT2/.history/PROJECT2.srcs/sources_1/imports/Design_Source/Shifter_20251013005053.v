`timescale 1ns/1ps
module Shifter(
    input [1:0]  Sh,
    input [4:0]  Shamt5,
    input        ShAmtFromReg,   // 新增：1=用寄存器提供移位量
    input [31:0] RsVal,          // 新增：Rs 的值
    input [31:0] ShIn,
    output [31:0] ShOut
);
  reg [31:0] r;
  wire [4:0] amt = ShAmtFromReg ? RsVal[4:0] : Shamt5;

  always @(*) begin
    case (Sh)
      2'b00: r = ShIn << amt;                    // LSL
      2'b01: r = ShIn >> amt;                    // LSR
      2'b10: r = $signed(ShIn) >>> amt;          // ASR
      default: r = (amt==0) ? ShIn
                             : ((ShIn >> amt) | (ShIn << (32-amt))); // ROR
    endcase
  end
  assign ShOut = r;
endmodule
