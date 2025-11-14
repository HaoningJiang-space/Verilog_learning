//-------------------------------------------------------------
// Module: ControlUnit
// Description: Control Unit for ARM CPU
//              - Integrates Decoder and Conditional Logic
//              - Generates all control signals for datapath
//              - Handles conditional execution
//-------------------------------------------------------------
module ControlUnit(
    input [31:0] Instr,
    input [3:0] ALUFlags,
    input CLK,

    output MemtoReg,
    output MemWrite,
    output ALUSrc,
    output [1:0] ImmSrc,
    output RegWrite,
    output [1:0] RegSrc,
    output [1:0] ALUControl,
    output PCSrc
);

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    wire [3:0] Cond;           // Condition field from instruction
    wire PCS, RegW, MemW;      // Unconditional control signals
    wire [1:0] FlagW;          // Flag write enable

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Extract Condition Field
    //====================================================
    assign Cond=Instr[31:28];

    //====================================================
    // Module Instantiations
    //====================================================

    // Conditional Logic Unit
    CondLogic CondLogic1(
        .CLK(CLK),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .FlagW(FlagW),
        .Cond(Cond),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );

    // Instruction Decoder
    Decoder Decoder1(
        .Instr(Instr),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .FlagW(FlagW)
    );

endmodule