`timescale 1ns/1ps
module Decoder(
    input  [31:0] Instr,
    // Sent through Control Unit
    output        PCS,
    output        RegW,
    output        MemW,
    output [1:0]  FlagW,
    // Sent directly to datapath
    output        MemtoReg,
    output        ALUSrc,
    output [1:0]  ImmSrc,
    output [1:0]  RegSrc,       // RegSrc[1]: A1 选 R15；RegSrc[0]: A2 选 Rd(STR)
    output [1:0]  ALUControl,   // 00 ADD, 01 SUB, 10 AND, 11 ORR
    output        NoWrite
);
    // 字段
    wire [1:0] op    = Instr[27:26];
    wire       I     = Instr[25];
    wire [3:0] funct = Instr[24:21];
    wire       Lbit  = Instr[20];       // op=01 时为 L，op=00 时为 S
    wire       S     = Instr[20];
    wire [3:0] Rd    = Instr[15:12];

    // 内部寄存
    reg PCS_d, RegW_d, MemW_d, MemtoReg_d, ALUSrc_d, NoWrite_d;
    reg [1:0] ImmSrc_d, RegSrc_d, ALUControl_d, FlagW_d;

    // 输出连线
    assign PCS        = PCS_d;
    assign RegW       = RegW_d;
    assign MemW       = MemW_d;
    assign MemtoReg   = MemtoReg_d;
    assign ALUSrc     = ALUSrc_d;
    assign ImmSrc     = ImmSrc_d;
    assign RegSrc     = RegSrc_d;
    assign ALUControl = ALUControl_d;
    assign FlagW      = FlagW_d;
    assign NoWrite    = NoWrite_d;

    // 主译码 + ALU/Flag 控制
    always @(*) begin
        // 缺省值
        PCS_d=0; RegW_d=0; MemW_d=0; MemtoReg_d=0; ALUSrc_d=0;
        ImmSrc_d=2'b00; RegSrc_d=2'b00; ALUControl_d=2'b00; FlagW_d=2'b00; NoWrite_d=1'b0;

        case (op)
            2'b10: begin // Branch
                ALUSrc_d     = 1'b1;
                ImmSrc_d     = 2'b10;      // 分支立即数
                RegSrc_d     = 2'b10;      // A1=R15
                ALUControl_d = 2'b00;      // PC + offset
                PCS_d        = 1'b1;
            end

            2'b01: begin // LDR/STR
                MemtoReg_d   = Lbit;
                MemW_d       = ~Lbit;
                RegW_d       = Lbit;
                ALUSrc_d     = 1'b1;
                ImmSrc_d     = 2'b01;      // 12-bit 地址偏移
                RegSrc_d     = {1'b0, ~Lbit}; // STR 时 A2=Rd
                ALUControl_d = 2'b00;      // Base + offset
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1; // LDR PC
            end

            default: begin // 2'b00: Data Processing
                ALUSrc_d = I;              // 立即数/寄存器
                // 功能码映射到 ALUControl，并决定 FlagW/NoWrite/RegW
                case (funct)
                    4'b0100: begin // ADD
                        ALUControl_d = 2'b00;
                        RegW_d       = 1'b1;
                        FlagW_d      = S ? 2'b11 : 2'b00; // 算术更 NZCV
                    end
                    4'b0010: begin // SUB
                        ALUControl_d = 2'b01;
                        RegW_d       = 1'b1;
                        FlagW_d      = S ? 2'b11 : 2'b00; // 算术更 NZCV
                    end
                    4'b0000: begin // AND
                        ALUControl_d = 2'b10;
                        RegW_d       = 1'b1;
                        FlagW_d      = S ? 2'b10 : 2'b00; // 逻辑更 NZ
                    end
                    4'b1100: begin // ORR
                        ALUControl_d = 2'b11;
                        RegW_d       = 1'b1;
                        FlagW_d      = S ? 2'b10 : 2'b00; // 逻辑更 NZ
                    end
                    4'b1010: begin // CMP -> SUB，不写回
                        ALUControl_d = 2'b01;
                        RegW_d       = 1'b0;
                        FlagW_d      = 2'b11;            // NZCV
                        NoWrite_d    = 1'b1;
                    end
                    4'b1011: begin // CMN -> ADD，不写回
                        ALUControl_d = 2'b00;
                        RegW_d       = 1'b0;
                        FlagW_d      = 2'b11;            // NZCV
                        NoWrite_d    = 1'b1;
                    end
                    4'b1000,       // TST -> AND，不写回
                    4'b1001: begin // TEQ -> AND，不写回
                        ALUControl_d = 2'b10;
                        RegW_d       = 1'b0;
                        FlagW_d      = 2'b10;            // NZ
                        NoWrite_d    = 1'b1;
                    end
                    default: begin
                        // 其他未覆盖 DP 指令：按 ADD 处理，不更新标志
                        ALUControl_d = 2'b00;
                        RegW_d       = 1'b1;
                        FlagW_d      = 2'b00;
                    end
                endcase
                if (RegW_d && (Rd==4'd15)) PCS_d = 1'b1; // 写回 PC
            end
        endcase
    end
endmodule