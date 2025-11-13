`timescale 1ns/1ps
module Shifter(
    input  [1:0]  Sh,       // 00 LSL, 01 LSR, 10 ASR, 11 ROR
    input  [4:0]  Shamt5,
    input  [31:0] ShIn,
    output [31:0] ShOut
);
    // 分级移位（16/8/4/2/1）硬件高效实现，严格按讲义的 case/路径
    reg [31:0] r;
    reg [31:0] s0, s1, s2, s3, s4, s5;

    always @(*) begin
        case (Sh)
            // 00: LSL 逻辑左移
            2'b00: begin
                s0 = ShIn;
                s1 = Shamt5[4] ? {s0[15:0], 16'b0} : s0;
                s2 = Shamt5[3] ? {s1[23:0], 8'b0}  : s1;
                s3 = Shamt5[2] ? {s2[27:0], 4'b0}  : s2;
                s4 = Shamt5[1] ? {s3[29:0], 2'b0}  : s3;
                s5 = Shamt5[0] ? {s4[30:0], 1'b0}  : s4;
                r  = s5;
            end

            // 01: LSR 逻辑右移（高位补零）
            2'b01: begin
                s0 = ShIn;
                s1 = Shamt5[4] ? {16'b0, s0[31:16]} : s0;
                s2 = Shamt5[3] ? {8'b0,  s1[31:8]}  : s1;
                s3 = Shamt5[2] ? {4'b0,  s2[31:4]}  : s2;
                s4 = Shamt5[1] ? {2'b0,  s3[31:2]}  : s3;
                s5 = Shamt5[0] ? {1'b0,  s4[31:1]}  : s4;
                r  = s5;
            end

            // 10: ASR 算术右移（高位补符号位）
            2'b10: begin
                s0 = ShIn;
                s1 = Shamt5[4] ? {{16{s0[31]}}, s0[31:16]} : s0;
                s2 = Shamt5[3] ? {{ 8{s1[31]}}, s1[31:8]}  : s1;
                s3 = Shamt5[2] ? {{ 4{s2[31]}}, s2[31:4]}  : s2;
                s4 = Shamt5[1] ? {{ 2{s3[31]}}, s3[31:2]}  : s3;
                s5 = Shamt5[0] ? {{ 1{s4[31]}}, s4[31:1]}  : s4;
                r  = s5;
            end

            // 11: ROR 右旋转（按 16/8/4/2/1 分级）
            default: begin
                s0 = ShIn;
                s1 = Shamt5[4] ? {s0[15:0], s0[31:16]} : s0;  // 右旋16
                s2 = Shamt5[3] ? {s1[7:0],  s1[31:8]}  : s1;  // 右旋8
                s3 = Shamt5[2] ? {s2[3:0],  s2[31:4]}  : s2;  // 右旋4
                s4 = Shamt5[1] ? {s3[1:0],  s3[31:2]}  : s3;  // 右旋2
                s5 = Shamt5[0] ? {s4[0],    s4[31:1]}  : s4;  // 右旋1
                r  = s5; // 若 Shamt5==0，自然直通 ShIn
            end
        endcase
    end

    assign ShOut = r;
endmodule
