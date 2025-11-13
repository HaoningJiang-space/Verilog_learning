`timescale 1ns/1ps
module Decoder(
    input  [31:0] Instr,
    output        PCS,
    output        RegW,
    output        MemW,
    output        MemtoReg,
    output        ALUSrc,
    output [1:0]  ImmSrc,
    output [1:0]  RegSrc,
    output reg [1:0] ALUControl, // 00 AND, 01 ADD, 10 SUB, 11 ORR
    output reg [1:0] FlagW       // [1]:NZ, [0]:CV
);
    // 字段
    wire [1:0] op    = Instr[27:26];
    wire       I     = Instr[25];
    wire       L     = Instr[20];
    wire [3:0] funct = Instr[24:21];
    wire       S     = Instr[20];
    wire [3:0] Rd    = Instr[15:12];
    wire       Branch= (op == 2'b10);

    // 内部寄存输出
    reg PCS_d, RegW_d, MemW_d, MemtoReg_d, ALUSrc_d;
    reg [1:0] ImmSrc_d, RegSrc_d;

    // 连到输出
    assign PCS      = PCS_d;
    assign RegW     = RegW_d;
    assign MemW     = MemW_d;
    assign MemtoReg = MemtoReg_d;
    assign ALUSrc   = ALUSrc_d;
    assign ImmSrc   = ImmSrc_d;
    assign RegSrc   = RegSrc_d;

    // ALU 操作选择（含 DP & 比较类映射）
    always @(*) begin
        ALUControl = 2'b01; // 默认 ADD
        case (op)
            2'b10: ALUControl = 2'b01; // Branch: PC + offset
            2'b01: ALUControl = 2'b01; // LDR/STR: base + offset
            2'b00: begin
                case (funct[3:0])
                    4'b0000: ALUControl = 2'b00; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b0100: ALUControl = 2'b01; // ADD
                    4'b0010: ALUControl = 2'b10; // SUB
                    4'b1000: ALUControl = 2'b00; // TST -> AND
                    4'b1001: ALUControl = 2'b00; // TEQ -> AND（简化）
                    4'b1010: ALUControl = 2'b10; // CMP -> SUB
                    4'b1011: ALUControl = 2'b01; // CMN -> ADD
                    default: ALUControl = 2'b01;
                endcase
            end
        endcase
    end

    // 主译码（与讲义表一致）
    always @(*) begin
        // 安全默认
        PCS_d      = 1'b0;
        RegW_d     = 1'b0;
        MemW_d     = 1'b0;
        MemtoReg_d = 1'b0;
        ALUSrc_d   = 1'b0;
        ImmSrc_d   = 2'b00;
        RegSrc_d   = 2'b00;
        FlagW      = 2'b00;

        casex (op)
            2'b10: begin // Branch
                ALUSrc_d = 1'b1;
                ImmSrc_d = 2'b10;
                RegSrc_d = 2'b10;     // A1<=R15
                PCS_d    = 1'b1;      // 关键：分支必须请求写PC
                FlagW    = 2'b00;     // Branch 不改标志
            end
            2'b01: begin // LDR/STR
                MemtoReg_d = L;       // LDR
                MemW_d     = ~L;      // STR
                RegW_d     = L;       // 仅 LDR 写回
                ALUSrc_d   = 1'b1;    // 12位偏移
                ImmSrc_d   = 2'b01;
                RegSrc_d   = {1'b0, ~L}; // RegSrc[0]=1 时 A2=Rd（STR）
                // 写R15也触发 PCS
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1;
                FlagW    = 2'b00;
            end
            2'b00: begin // Data Processing
                // 只更新标志的指令不写回
                case (funct[3:0])
                    4'b1000,4'b1001,4'b1010,4'b1011: RegW_d = 1'b0; // TST/TEQ/CMP/CMN
                    default: RegW_d = 1'b1;
                endcase
                ALUSrc_d = I;         // 立即数或寄存器
                ImmSrc_d = 2'b00;
                RegSrc_d = 2'b00;
                // S 位时写标志（简化：NZ/CV全写）
                FlagW    = S ? 2'b11 : 2'b00;
                // 写R15触发 PCS
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1;
            end
        endcase
    end
endmodule