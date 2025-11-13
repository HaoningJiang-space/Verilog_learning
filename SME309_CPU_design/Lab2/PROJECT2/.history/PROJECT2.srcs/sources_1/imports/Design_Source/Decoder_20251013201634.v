`timescale 1ns/1ps
module Decoder(
    input  [31:0] Instr,
    output        PCS,
    output        RegW,
    output        MemW,
    output        MemtoReg,
    output        ALUSrc,
    output [1:0]  ImmSrc,
    output [1:0]  RegSrc,      // RegSrc[1]: A1 选 R15；RegSrc[0]: A2 选 Rd(STR)
    output reg [1:0] ALUControl, // 00 ADD, 01 SUB, 10 AND, 11 ORR
    output reg [1:0] FlagW       // [1]:NZ, [0]:CV
);
    // 字段
    wire [1:0] op    = Instr[27:26];
    wire       I     = Instr[25];
    wire       L     = Instr[20];
    wire [3:0] funct = Instr[24:21];
    wire       S     = Instr[20];
    wire [3:0] Rd    = Instr[15:12];

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

    // ALUControl 映射（与 ALU 一致）
    always @(*) begin
        ALUControl = 2'b00;
        case (op)
            2'b10: ALUControl = 2'b00; // Branch: ADD
            2'b01: ALUControl = 2'b00; // LDR/STR: base + offset
            2'b00: begin
                case (funct)
                    4'b0100: ALUControl = 2'b00; // ADD
                    4'b0010: ALUControl = 2'b01; // SUB
                    4'b0000: ALUControl = 2'b10; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b1010: ALUControl = 2'b01; // CMP -> SUB
                    4'b1011: ALUControl = 2'b00; // CMN -> ADD
                    4'b1000: ALUControl = 2'b10; // TST -> AND
                    4'b1001: ALUControl = 2'b10; // TEQ -> AND
                    default: ALUControl = 2'b00;
                endcase
            end
        endcase
    end

    // 主译码
    always @(*) begin
        PCS_d=0; RegW_d=0; MemW_d=0; MemtoReg_d=0; ALUSrc_d=0;
        ImmSrc_d=2'b00; RegSrc_d=2'b00; FlagW=2'b00;

        case (op)
            2'b10: begin // Branch
                ALUSrc_d = 1'b1;
                ImmSrc_d = 2'b10;
                RegSrc_d = 2'b10;     // A1=R15（与你的 ARM.v 位向一致）
                PCS_d    = 1'b1;
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
                ALUSrc_d = I;
                // 比较/测试类：不写寄存器
                case (funct)
                    4'b1000,4'b1001: begin // TST/TEQ
                        RegW_d = 1'b0;
                        FlagW  = 2'b10;    // 只更 NZ
                    end
                    4'b1010,4'b1011: begin // CMP/CMN
                        RegW_d = 1'b0;
                        FlagW  = 2'b11;    // 更 NZCV
                    end
                    default: begin
                        RegW_d = 1'b1;
                        FlagW  = S ? ((ALUControl[1]==1'b1)? 2'b10 : 2'b11) : 2'b00;
                        // S=1 时：逻辑类(AND/ORR)更 NZ；算术类(ADD/SUB)更 NZCV
                    end
                endcase
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1;
            end
        endcase
    end
endmodule