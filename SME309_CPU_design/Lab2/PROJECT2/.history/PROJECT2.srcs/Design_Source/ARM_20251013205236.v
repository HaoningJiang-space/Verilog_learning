`timescale 1ns/1ps
module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,        //Instruction 
    input [31:0] ReadData,     //Read Data from Data Memory
 
    output MemWrite,           //Control signal to Data Memory
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData    //Write Data to Data Memory
    );

    wire [31:0] Result_PC_in;                //Result input to Program Counter
    wire [31:0] PC_Plus_4;                   //Program Counter + 4
    wire [31:0] PC_Plus_8=PC_Plus_4+32'd4;   //Program Counter + 8

    wire       MemtoReg, ALUSrc, RegWrite;   //Control signals
    wire [1:0] ImmSrc, RegSrc, ALUControl;   //Control signals
    wire       PCSrc;                        //Control signal

    wire [3:0]  Register_A1,Register_A2, Register_A3;   //Register addresses 
    wire [31:0] Register_ReadData1, Register_ReadData2; //Data read from registers
    wire [31:0] Register_WriteData;                     //Data to write to register
    wire [31:0] RegisterR15;                            //Value of R15 (PC)
    wire        WE3;                                    //Write Enable for Register File

    wire [1:0]  Sh;                          //Shift Type
    wire [4:0]  Shamt5;                      //Shift Amount
    wire [31:0] ShIn  ;                      //Before Shift 
    wire [31:0] ShOut ;                      //After Shift 
    
    wire [31:0] ALUSrc_A;                    //ALU Source A
    wire [31:0] ALUSrc_B;                    //ALU Source B
    wire [3:0]  ALUFlags;                    //Flags from ALU
    
    wire [23:0] InstrImm = Instr[23:0];      //Immediate value from instruction (24-bit)
    wire [31:0] ExtImm;                      //Extended immediate value

    //mux
    assign Result_PC_in = (MemtoReg) ? ReadData     : ALUResult;       // Result to PC input
    // 修正：RegSrc[1] 控 A1=R15；RegSrc[0] 控 A2=Rd
    assign Register_A1  = (RegSrc[1])? 4'd15       : Instr[19:16];    // A1
    assign Register_A2  = (RegSrc[0])? Instr[15:12] : Instr[3:0];      // A2
    assign Register_A3  = Instr[15:12];                                // A3
    assign Register_WriteData = (MemtoReg) ? ReadData : ALUResult;     // WD3
    assign RegisterR15 =  PC_Plus_8;                                   // R15
    assign ALUSrc_A = Register_ReadData1;                              // ALU Src A
    assign ALUSrc_B = (ALUSrc) ? ExtImm : ShOut;                       // ALU Src B
    assign WE3      = RegWrite;
    assign ShIn     = Register_ReadData2;
    assign Shamt5   = Instr[11:7];
    assign Sh       = Instr[6:5];

    ProgramCounter PC_Reg(
        .CLK(CLK),
        .Reset(Reset),
        .PCSrc(PCSrc),
        .Result(Result_PC_in),
        .PC(PC),
        .PC_Plus_4(PC_Plus_4)
    );

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

    ALU ALU_Unit(
        .Src_A(ALUSrc_A),
        .Src_B(ALUSrc_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );
    
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
    
    // 补齐 Shifter
    Shifter Shifter_Unit(
        .Sh(Sh),
        .Shamt5(Shamt5),
        .ShIn(ShIn),
        .ShOut(ShOut)
    );

    // 补齐 Extend（用于生成 ExtImm）
    Extend Extend_Unit(
        .ImmSrc(ImmSrc),
        .InstrImm(InstrImm),
        .ExtImm(ExtImm)
    );

    assign WriteData = Register_ReadData2; // Data to write to Data Memory
endmodule