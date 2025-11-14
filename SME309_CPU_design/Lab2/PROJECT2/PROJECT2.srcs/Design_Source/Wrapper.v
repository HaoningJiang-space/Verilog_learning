//-------------------------------------------------------------
// Module: Wrapper
// Description: ARM CPU Wrapper Module
//              - Integrates ARM core with memory system
//              - Manages instruction and data memory
//              - Handles memory address decoding
//              - Provides I/O interface (LEDs, 7-segment display)
// Note: FOR SIMULATION. DO NOT SYNTHESIZE DIRECTLY
//       (Used as a component in TOP.v for Synthesis)
//-------------------------------------------------------------
`timescale 1ns / 1ps

module Wrapper
#(
    parameter N_LEDs = 16,       // Number of LEDs displaying PC value
    parameter N_DIPs = 7         // Number of DIP switches for memory address
)
(
    input  [N_DIPs-1:0] DIP,         // DIP switch inputs for memory address
    output reg [N_LEDs-1:0] LED,     // LED display for program counter
    output reg [31:0] SEVENSEGHEX,   // 7-segment display for memory content
    input  RESET,                    // Active high reset
    input  CLK                       // Divided clock from TOP
);

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    // ARM CPU signals
    wire [31:0] PC;          // Program Counter
    wire [31:0] Instr;       // Instruction from memory
    reg  [31:0] ReadData;    // Data read from memory
    wire MemWrite;           // Memory write enable
    wire [31:0] ALUResult;   // ALU result (memory address)
    wire [31:0] WriteData;   // Data to write to memory

    // Address Decode signals
    wire dec_DATA_CONST, dec_DATA_VAR;  // Memory region enable signals

    // Memory read for I/O
    wire [31:0] ReadData_IO; // Memory data for display

    // Memory arrays
    reg [31:0] INSTR_MEM     [0:127]; // Instruction memory (128 words)
    reg [31:0] DATA_CONST_MEM[0:127]; // Constant data memory (128 words)
    reg [31:0] DATA_VAR_MEM  [0:127]; // Variable data memory (128 words)
    integer i;


//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Instruction Memory Initialization
    //====================================================
    initial begin
			INSTR_MEM[0] = 32'hE59F1204; 
			INSTR_MEM[1] = 32'hE59F2204; 
			INSTR_MEM[2] = 32'hE59F31F0; 
			INSTR_MEM[3] = 32'hE59F41F0; 
			INSTR_MEM[4] = 32'hE0815002; 
			INSTR_MEM[5] = 32'hE5835004; 
			INSTR_MEM[6] = 32'hE2833008; 
			INSTR_MEM[7] = 32'hE5135004; 
			INSTR_MEM[8] = 32'hE0416002; 
			INSTR_MEM[9] = 32'hE5046004; 
			INSTR_MEM[10] = 32'hE2444008; 
			INSTR_MEM[11] = 32'hE5946004; 
			INSTR_MEM[12] = 32'hE2013000; 
			INSTR_MEM[13] = 32'hE59FA1D8; 
			INSTR_MEM[14] = 32'hE181400A; 
			INSTR_MEM[15] = 32'hE1811004; 
			INSTR_MEM[16] = 32'hE0022003; 
			INSTR_MEM[17] = 32'hE0017801; 
			INSTR_MEM[18] = 32'hE0018821; 
			INSTR_MEM[19] = 32'hE0017447; 
			INSTR_MEM[20] = 32'hE0018848; 
			INSTR_MEM[21] = 32'hE0889005; 
			INSTR_MEM[22] = 32'hE047A006; 
			INSTR_MEM[23] = 32'hE04AB009; 
			INSTR_MEM[24] = 32'hE04BB009; 
			INSTR_MEM[25] = 32'hE001B86B; 
			INSTR_MEM[26] = 32'hE59FA1A8; 
			INSTR_MEM[27] = 32'hE04BB00A; 
			INSTR_MEM[28] = 32'hE28B3000; 
			INSTR_MEM[29] = 32'hE59F11A0; 
			INSTR_MEM[30] = 32'hE59F219C; 
			INSTR_MEM[31] = 32'hE24BB001; 
			INSTR_MEM[32] = 32'hE2811001; 
			INSTR_MEM[33] = 32'hE35B0002; 
			INSTR_MEM[34] = 32'h1AFFFFFB; 
			INSTR_MEM[35] = 32'hE2433001; 
			INSTR_MEM[36] = 32'hE2822002; 
			INSTR_MEM[37] = 32'hE3530001; 
			INSTR_MEM[38] = 32'h1AFFFFFB; 
			INSTR_MEM[39] = 32'hE081B002; 
			INSTR_MEM[40] = 32'hE38BB001; 
			INSTR_MEM[41] = 32'hE20BB00C; 
			INSTR_MEM[42] = 32'hE59F1164; 
			INSTR_MEM[43] = 32'hE001B26B; 
			INSTR_MEM[44] = 32'hE59F115C; 
			INSTR_MEM[45] = 32'hE59F2150; 
			INSTR_MEM[46] = 32'hE59F3150; 
			INSTR_MEM[47] = 32'hE082B24B; 
			INSTR_MEM[48] = 32'hE082B22B; 
			INSTR_MEM[49] = 32'hE082B20B; 
			INSTR_MEM[50] = 32'hE082B26B; 
			INSTR_MEM[51] = 32'hE00BB221; 
			INSTR_MEM[52] = 32'hE183B20B; 
			INSTR_MEM[53] = 32'hE041B86B; 
			INSTR_MEM[54] = 32'hE59FA128; 
			INSTR_MEM[55] = 32'hE58AB000; 
			INSTR_MEM[56] = 32'hE59F911C; 
			INSTR_MEM[57] = 32'hE5891000; 
			INSTR_MEM[58] = 32'hEAFFFFFE; 
			for(i = 59; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

    //====================================================
    // Data (Constant) Memory Initialization
    //====================================================
    initial begin
			DATA_CONST_MEM[0] = 32'h00000810; 
			DATA_CONST_MEM[1] = 32'h00000820; 
			DATA_CONST_MEM[2] = 32'h00000830; 
			DATA_CONST_MEM[3] = 32'h00000002; 
			DATA_CONST_MEM[4] = 32'h00000001; 
			DATA_CONST_MEM[5] = 32'hFFFFFFFF; 
			DATA_CONST_MEM[6] = 32'hFEF9FFF9; 
			for(i = 7; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

    //====================================================
    // Data (Variable) Memory Initialization
    //====================================================
    initial begin
            for(i = 0; i < 128; i = i+1) begin 
				DATA_VAR_MEM[i] = 32'h0; 
			end
end


    //====================================================
    // ARM CPU Instantiation
    //====================================================
    ARM ARM1(
        .CLK(CLK),
        .Reset(RESET),
        .Instr(Instr),
        .ReadData(ReadData),
        .MemWrite(MemWrite),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData)
    );

    //====================================================
    // Data Memory Address Decoding
    //====================================================
    // Memory map:
    // 0x00000200 - 0x000003FC: Constant data memory
    // 0x00000800 - 0x000009FC: Variable data memory
    assign dec_DATA_CONST = (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
    assign dec_DATA_VAR   = (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;

    //====================================================
    // Data Memory Read (for CPU)
    //====================================================
    always@( * ) begin
        if (dec_DATA_VAR)
            ReadData <= DATA_VAR_MEM[ALUResult[8:2]];
        else if (dec_DATA_CONST)
            ReadData <= DATA_CONST_MEM[ALUResult[8:2]];
        else
            ReadData <= 32'h0;
    end

    //====================================================
    // Data Memory Read (for Display)
    //====================================================
    assign ReadData_IO = DATA_VAR_MEM[DIP[6:0]]; // Used for 7-segment display

    //====================================================
    // Data Memory Write
    //====================================================
    always@(posedge CLK) begin
        if( MemWrite && dec_DATA_VAR )
            DATA_VAR_MEM[ALUResult[8:2]] <= WriteData;
    end

    //====================================================
    // Instruction Memory Read
    //====================================================
    // Valid address range: 0x00000000 - 0x000001FC (128 words)
    // PC increments by 4, so use bits [8:2] for indexing
    assign Instr = ( (PC >= 32'h00000000) && (PC <= 32'h000001FC) ) ?
                     INSTR_MEM[PC[8:2]] : 32'h00000000;

    //====================================================
    // LED Display - Program Counter Value
    //====================================================
    always@(posedge CLK or posedge RESET) begin
        if(RESET)
            LED <= 16'b0;
        else
            LED <= PC;
    end

    //====================================================
    // Seven-Segment Display - Memory Content
    //====================================================
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            SEVENSEGHEX <= 32'b0;
        else
            SEVENSEGHEX <= ReadData_IO;
    end

endmodule
