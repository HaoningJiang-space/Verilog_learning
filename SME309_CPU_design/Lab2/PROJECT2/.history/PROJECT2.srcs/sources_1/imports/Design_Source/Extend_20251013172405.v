`timescale 1ns/1ps
module Extend(
    input  [1:0]  ImmSrc,      // 00 DP imm (ARM: ROR(imm8, 2*rot)), 01 LS imm12, 10 Branch imm24
    input  [23:0] InstrImm,
    output reg [31:0] ExtImm
);
    wire [25:0] imm26 = {InstrImm, 2'b00}; // for branch

    // ROR32: 32 位循环右移函数
    function [31:0] ror32;
        input [31:0] x;
        input [4:0]  sh; // 0..31
        begin
            ror32 = (sh == 0) ? x : ((x >> sh) | (x << (32 - sh)));
        end
    endfunction

    always @(*) begin
        case (ImmSrc)
            // 数据处理立即数：ExtImm = ROR({24'b0, imm8}, 2*rot)，其中 rot=InstrImm[11:8]
            2'b00: begin
                // rot 是 4 位，范围 0..15，ARM 规定旋转量为 2*rot（0..30）
                // 先把 imm8 放到低 8 位，再做 32 位 ROR
                reg [3:0] rot;
                reg [4:0] amt;
                reg [31:0] imm32;
                rot   = InstrImm[11:8];
                amt   = {rot, 1'b0};     // 2*rot (5 位，0..30)
                imm32 = {24'b0, InstrImm[7:0]};
                ExtImm = ror32(imm32, amt);
            end
            // LDR/STR 12 位无符号偏移
            2'b01: ExtImm = {20'b0, InstrImm[11:0]};
            // Branch: signext(imm24<<2)
            2'b10: ExtImm = {{6{imm26[25]}}, imm26};
            default: ExtImm = 32'b0;
        endcase
    end
endmodule
