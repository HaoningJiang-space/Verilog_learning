`timescale 1ns/1ps
module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,
    input [31:0] ReadData,

    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
); 

    // Control signals
    wire MemtoReg, ALUSrc, RegWrite, PCSrc;
    wire [1:0] ImmSrc, RegSrc, ALUControl;
    wire [3:0] ALUFlags;

    // Datapath wires
    wire [31:0] PCPlus4, ExtImm;
    wire [31:0] RD1, RD2; // register file read ports
    wire [31:0] SrcA, SrcB;

    // Program Counter
    ProgramCounter PC1(
        .CLK(CLK),
        .Reset(Reset),
        .PCSrc(PCSrc),
        .Result(ALUResult),
        .PC(PC),
        .PC_Plus_4(PCPlus4)
    );

    // Control Unit
    ControlUnit CU1(
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        .CLK(CLK),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .PCSrc(PCSrc)
    );

    // Register File address muxing according to RegSrc[1:0]
    wire [3:0] RA1 = RegSrc[0] ? 4'd15 : Instr[19:16]; // Rn or PC
    wire [3:0] RA2 = RegSrc[1] ? Instr[15:12] : Instr[3:0]; // Rt for STR else Rm
    wire [31:0] PCPlus8 = PCPlus4 + 32'd4; // R15 value (PC+8)

    RegisterFile RF1(
        .CLK(CLK),
        .WE3(RegWrite),
        .A1(RA1),
        .A2(RA2),
        .A3(Instr[15:12]), // Rd
        .WD3(MemtoReg ? ReadData : ALUResult),
        .R15(PCPlus8),
        .RD1(RD1),
        .RD2(RD2)
    );

    // Extend immediate
    Extend EXT1(
        .ImmSrc(ImmSrc),
        .InstrImm(Instr[23:0]),
        .ExtImm(ExtImm)
    );

    // Shifter for operand2 immediate shift (simplified: use Instr[6:5] and [11:7])
    wire [31:0] ShOut;
    Shifter SH1(
        .Sh(Instr[6:5]),
        .Shamt5(Instr[11:7]),
        .ShIn(RD2),
        .ShOut(ShOut)
    );

    assign SrcA = RD1;
    assign SrcB = ALUSrc ? ExtImm : ShOut;

    // ALU
    ALU ALU1(
        .Src_A(SrcA),
        .Src_B(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Write data to memory (from register port B)
    assign WriteData = RD2;

endmodule