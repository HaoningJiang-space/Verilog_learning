`timescale 1ns/1ps
module ARM(
    input        CLK,
    input        Reset,
    input  [31:0] Instr,
    input  [31:0] ReadData,
    output        MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
);
    wire        MemtoReg, ALUSrc, RegWrite, PCSrc;
    wire [1:0]  ImmSrc, RegSrc, ALUControl;
    wire [3:0]  ALUFlags;

    // PC + 4 / +8
    wire [31:0] PC_Plus_4;
    wire [31:0] PC_Plus_8 = PC_Plus_4 + 32'd4;

    // 寄存器堆读口选择
    wire [3:0] RA1 = RegSrc[1] ? 4'd15 : Instr[19:16]; // Rn or R15
    wire [3:0] RA2 = RegSrc[0] ? Instr[15:12] : Instr[3:0]; // Rd(for STR) or Rm
    wire [31:0] RD1, RD2;

    // 立即数扩展与移位
    wire [31:0] ExtImm;
    wire [31:0] ShOut;

    // 源操作数选择
    wire [31:0] SrcA = RD1;
    wire [31:0] SrcB = ALUSrc ? ExtImm : ShOut;

    // 写回数据
    assign WriteData = RD2;
    wire [31:0] Result = MemtoReg ? ReadData : ALUResult;

    ProgramCounter u_pc(
        .CLK(CLK), .Reset(Reset),
        .PCSrc(PCSrc), .Result(Result),
        .PC(PC), .PC_Plus_4(PC_Plus_4)
    );

    RegisterFile u_rf(
        .CLK(CLK), .WE3(RegWrite),
        .A1(RA1), .A2(RA2), .A3(Instr[15:12]),
        .WD3(Result),
        .R15(PC_Plus_8),
        .RD1(RD1), .RD2(RD2)
    );

    Shifter u_sh(
        .Sh(Instr[6:5]),
        .Shamt5(Instr[11:7]),
        .ShIn(RD2),
        .ShOut(ShOut)
    );

    Extend u_ext(
        .ImmSrc(ImmSrc),
        .InstrImm(Instr[23:0]),
        .ExtImm(ExtImm)
    );

    ALU u_alu(
        .Src_A(SrcA), .Src_B(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    ControlUnit u_cu(
        .CLK(CLK), .Reset(Reset),
        .Instr(Instr), .ALUFlags(ALUFlags),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl)
    );
endmodule