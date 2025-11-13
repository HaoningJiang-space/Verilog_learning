`timescale 1ns/1ps
module ControlUnit(
    input        CLK,
    input        Reset,
    input  [31:0] Instr,
    input  [3:0]  ALUFlags,
    output        PCSrc,
    output        RegWrite,
    output        MemWrite,
    output        MemtoReg,
    output        ALUSrc,
    output [1:0]  ImmSrc,
    output [1:0]  RegSrc,
    output [1:0]  ALUControl
);
    wire [1:0] FlagW;
    wire       PCS;

    Decoder u_dec(
        .Instr(Instr),
        .PCS(PCS),
        .RegW(RegWrite),
        .MemW(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .FlagW(FlagW)
    );

    CondLogic u_cond(
        .CLK(CLK),
        .PCS(PCS),
        .RegW(RegWrite),
        .MemW(MemWrite),
        .FlagW(FlagW),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc),
        .RegWrite(),
        .MemWrite()
    );
    // 注意：CondLogic 已经门控了 RegWrite/MemWrite，
    // 如果你希望外部用门控后的信号，把上面两个输出接出来替换直连版本。
endmodule