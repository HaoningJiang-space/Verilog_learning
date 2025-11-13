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
    output reg [1:0] ALUControl, // 修正注释：00 ADD, 01 SUB, 10 AND, 11 ORR
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

    // ALU 操作选择（与 ALU 一致：00 ADD, 01 SUB, 10 AND, 11 ORR）
    always @(*) begin
        ALUControl = 2'b00; // 默认 ADD
        case (op)
            2'b10: ALUControl = 2'b00; // Branch -> ADD
            2'b01: ALUControl = 2'b00; // LDR/STR -> ADD
            2'b00: begin // Data Processing
                case (funct[3:0])
                    4'b0000: ALUControl = 2'b10; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b0100: ALUControl = 2'b00; // ADD
                    4'b0010: ALUControl = 2'b01; // SUB
                    4'b1000: ALUControl = 2'b10; // TST -> AND
                    4'b1001: ALUControl = 2'b10; // TEQ -> AND
                    4'b1010: ALUControl = 2'b01; // CMP -> SUB
                    4'b1011: ALUControl = 2'b00; // CMN -> ADD
                    default: ALUControl = 2'b00;
                endcase
            end
        endcase
    end

    // 主译码
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
                RegSrc_d = 2'b10;   // A1=R15(PC+8)
                PCS_d    = 1'b1;    // 请求写PC
            end
            2'b01: begin // LDR/STR
                MemtoReg_d = L;
                MemW_d     = ~L;
                RegW_d     = L;
                ALUSrc_d   = 1'b1;
                ImmSrc_d   = 2'b01;
                RegSrc_d   = {1'b0, ~L}; // STR: A2=Rd
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1;
            end
            2'b00: begin // Data Processing
                ALUSrc_d = I;         // 立即数或寄存器
                ImmSrc_d = 2'b00;
                RegSrc_d = 2'b00;

                // 比较/测试类：不写寄存器，但必须写标志
                case (funct[3:0])
                    4'b1000,4'b1001,4'b1010,4'b1011: begin
                        RegW_d = 1'b0;       // TST/TEQ/CMP/CMN
                        FlagW  = 2'b11;      // 必写 NZ/CV
                    end
                    default: begin
                        RegW_d = 1'b1;       // 其他 DP 正常写回
                        FlagW  = S ? 2'b11 : 2'b00; // S=1 时写标志
                    end
                endcase

                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1; // 写 R15 视为写PC
            end
        endcase
    end
endmodule