`timescale 1ns/1ps
module Extend(
    input  [1:0]  ImmSrc,      // 00 DP imm(简化), 01 LS imm12, 10 Branch imm24
    input  [23:0] InstrImm,
    output reg [31:0] ExtImm
);
    wire [25:0] imm26 = {InstrImm, 2'b00}; // for branch
    always @(*) begin
        case (ImmSrc)
            2'b00: ExtImm = {24'b0, InstrImm[7:0]};      // 简化版 DP imm
            2'b01: ExtImm = {20'b0, InstrImm[11:0]};     // LDR/STR 无符号偏移
            2'b10: ExtImm = {{6{InstrImm[23]}}, InstrImm, 2'b00}; // branch: sign-extend imm24 then <<2
            default: ExtImm = 32'b0;
        endcase
    end
endmodule
