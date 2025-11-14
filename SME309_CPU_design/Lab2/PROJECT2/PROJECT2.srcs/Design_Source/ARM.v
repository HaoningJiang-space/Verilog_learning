//-------------------------------------------------------------
// Module: ARM
// Description: ARM CPU Datapath
//              - Integrates PC, Register File, ALU, Shifter, Extend
//              - Connects all datapath components
//              - Implements single-cycle ARM processor
//-------------------------------------------------------------
module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,        // Instruction from memory
    input [31:0] ReadData,     // Read Data from Data Memory

    output MemWrite,           // Control signal to Data Memory
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData    // Write Data to Data Memory
);

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    // Program Counter signals
    wire [31:0] Result_PC_in;                // Result input to Program Counter
    wire [31:0] PC_Plus_4;                   // Program Counter + 4
    wire [31:0] PC_Plus_8=PC_Plus_4+32'd4;   // Program Counter + 8

    // Control signals
    wire       MemtoReg, ALUSrc, RegWrite;   // Memory and Register control
    wire [1:0] ImmSrc, RegSrc, ALUControl;   // Source selection and ALU control
    wire       PCSrc;                        // PC source selection

    // Register File signals
    wire [3:0]  Register_A1,Register_A2, Register_A3;   // Register addresses
    wire [31:0] Register_ReadData1, Register_ReadData2; // Data read from registers
    wire [31:0] Register_WriteData;                     // Data to write to register
    wire [31:0] RegisterR15;                            // Value of R15 (PC)
    wire        WE3;                                    // Write Enable for Register File

    // Shifter signals
    wire [1:0]  Sh;                          // Shift Type
    wire [4:0]  Shamt5;                      // Shift Amount
    wire [31:0] ShIn  ;                      // Before Shift
    wire [31:0] ShOut ;                      // After Shift

    // ALU signals
    wire [31:0] ALUSrc_A;                    // ALU Source A
    wire [31:0] ALUSrc_B;                    // ALU Source B
    wire [3:0]  ALUFlags;                    // Flags from ALU

    // Immediate extension signals
    wire [31:0] InstrImm=Instr[23:0];        // Immediate value from instruction
    wire [31:0] ExtImm;                      // Extended immediate value

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Multiplexer Logic
    //====================================================
    assign Result_PC_in = (MemtoReg) ? ReadData     : ALUResult;       // Result to PC input
    assign Register_A1  = (RegSrc[0])? 32'd15       : Instr[19:16];    // A1
    assign Register_A2  = (RegSrc[1])? Instr[15:12] : Instr[3:0];      // A2
    assign Register_A3  = Instr[15:12];                                // A3
    assign Register_WriteData = (MemtoReg) ? ReadData : ALUResult;     // WD3
    assign RegisterR15 =  PC_Plus_8;                                   // R15
    assign ALUSrc_A = Register_ReadData1;                              // ALU Src A
    assign ALUSrc_B = (ALUSrc) ? ExtImm : ShOut;                       // ALU Src B
    assign WE3      = RegWrite;
    assign ShIn     = Register_ReadData2;
    assign Shamt5   = Instr[11:7];
    assign Sh       = Instr[6:5];

    //====================================================
    // Module Instantiations
    //====================================================

    // Program Counter
    ProgramCounter PC_Reg(
        .CLK(CLK),
        .Reset(Reset),
        .PCSrc(PCSrc),
        .Result(Result_PC_in),
        .PC(PC),
        .PC_Plus_4(PC_Plus_4)
    );

    // Control Unit
    ControlUnit u_ControlUnit(
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

    // Arithmetic Logic Unit
    ALU ALU_Unit(
        .Src_A(ALUSrc_A),
        .Src_B(ALUSrc_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Register File
    RegisterFile Reg_File(
        .CLK(CLK),
        .WE3(WE3),
        .A1(Register_A1),
        .A2(Register_A2),
        .A3(Register_A3),
        .WD3(Register_WriteData),
        .R15(RegisterR15),
        .RD1(Register_ReadData1),
        .RD2(Register_ReadData2)
    );

    // Barrel Shifter
    Shifter Shifter_Unit(
        .Sh(Sh),
        .Shamt5(Shamt5),
        .ShIn(ShIn),
        .ShOut(ShOut)
    );

    // Immediate Extender
    Extend Extend_Unit(
        .ImmSrc(ImmSrc),
        .InstrImm(InstrImm),
        .ExtImm(ExtImm)
    );

    //====================================================
    // Output Assignments
    //====================================================
    assign WriteData = Register_ReadData2; // Data to write to Data Memory

endmodule