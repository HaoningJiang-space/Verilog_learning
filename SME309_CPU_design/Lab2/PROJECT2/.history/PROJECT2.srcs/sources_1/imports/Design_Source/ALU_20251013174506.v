`timescale 1ns/1ps
module ALU(
    input  [31:0] Src_A,
    input  [31:0] Src_B,
    input  [1:0]  ALUControl,   // 00 AND, 01 ADD, 10 SUB, 11 ORR
    output [31:0] ALUResult,
    output [3:0]  ALUFlags      // {N,Z,C,V}
);
    reg  [31:0] result_r;
    reg  N, Z, C, V;

    // 统一加法器：SUB 使用 B 取反并加 1
    wire is_sub       = (ALUControl == 2'b01);
    wire [31:0] B2    = is_sub ? ~Src_B : Src_B;   // 对 SUB 取反 B，否则直通
    wire        cin   = is_sub ? 1'b1   : 1'b0;
    wire [32:0] sum_ext = {1'b0, Src_A} + {1'b0, B2} + cin;

    // 按 PDF 思路：仅在“算术类（ADD/SUB）”更新 C/V；逻辑类清零。
    // 注意：在本工程的编码中，ADD=01，SUB=10，AND=00，ORR=11
    // 因此“算术类”≠(~ALUControl[1])，而是 (ALUControl==01 || ALUControl==10)。
    wire arithmetic_op = (ALUControl == 2'b01) || (ALUControl == 2'b10);

    always @(*) begin
        // 计算结果
        case (ALUControl)
            2'b10: result_r = Src_A & Src_B;        // AND
            2'b00: result_r = sum_ext[31:0];        // ADD
            2'b01: result_r = sum_ext[31:0];        // SUB
            default: result_r = Src_A | Src_B;      // ORR
        endcase

        // N/Z 直接来自结果
        N = result_r[31];
        Z = (result_r == 32'b0);

        // C：sum_ext[32]，仅对算术类有效（等价于 PDF 的 &~ALUControl[1] 门控）
        C = arithmetic_op ? sum_ext[32] : 1'b0;     // SUB 时为 no-borrow 语义

        // V：~(A31 ^ B2[31]) & (sum31 ^ A31)，仅对算术类有效
        // 该形式与 PDF 的 ~(ALUControl[0]^A31^B31)&(sum31^A31) 等价（当 B2[31]=B31^is_sub）
        V = arithmetic_op ? (~(Src_A[31] ^ B2[31]) & (sum_ext[31] ^ Src_A[31])) : 1'b0;
    end

    assign ALUResult = result_r;
    assign ALUFlags  = {N, Z, C, V};
endmodule












