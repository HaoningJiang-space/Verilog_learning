//-------------------------------------------------------------
// Module: Shifter
// Description: Barrel Shifter for ARM CPU
//              - Supports LSL, LSR, ASR, ROR shift operations
//              - 5-bit shift amount (0-31 positions)
//              - Implemented as combinational logic
//-------------------------------------------------------------
module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,

    output [31:0] ShOut
);

//-------------------------------------------------------------
// PARAMETER
//-------------------------------------------------------------
    // Shift type encoding:
    // 00: LSL (Logical Shift Left)
    // 01: LSR (Logical Shift Right)
    // 10: ASR (Arithmetic Shift Right)
    // 11: ROR (Rotate Right)

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    // LSL intermediate signals
    wire [31:0] ShOutLSL;
    wire [31:0] ShOutA_LSL;
    wire [31:0] ShOutB_LSL;
    wire [31:0] ShOutC_LSL;
    wire [31:0] ShOutD_LSL;

    // LSR intermediate signals
    wire [31:0] ShOutLSR;
    wire [31:0] ShOutA_LSR;
    wire [31:0] ShOutB_LSR;
    wire [31:0] ShOutC_LSR;
    wire [31:0] ShOutD_LSR;

    // ASR intermediate signals
    wire [31:0] ShOutASR;
    wire [31:0] ShOutA_ASR;
    wire [31:0] ShOutB_ASR;
    wire [31:0] ShOutC_ASR;
    wire [31:0] ShOutD_ASR;

    // ROR intermediate signals
    wire [31:0] ShOutROR;
    wire [31:0] ShOutA_ROR;
    wire [31:0] ShOutB_ROR;
    wire [31:0] ShOutC_ROR;
    wire [31:0] ShOutD_ROR;

    reg  [31:0] ShOut_r;

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // LSL - Logical Shift Left
    //====================================================
    // Shift by 16, 8, 4, 2, 1 positions based on Shamt5 bits
    assign ShOutA_LSL = (Shamt5[4])?{ShIn[15:0],16'b0}:ShIn;
    assign ShOutB_LSL = (Shamt5[3])?{ShOutA_LSL[23:0],8'b0}:ShOutA_LSL;
    assign ShOutC_LSL = (Shamt5[2])?{ShOutB_LSL[27:0],4'b0}:ShOutB_LSL;
    assign ShOutD_LSL = (Shamt5[1])?{ShOutC_LSL[29:0],2'b0}:ShOutC_LSL;
    assign ShOutLSL   = (Shamt5[0])?{ShOutD_LSL[30:0],1'b0}:ShOutD_LSL;

    //====================================================
    // LSR - Logical Shift Right
    //====================================================
    // Shift by 16, 8, 4, 2, 1 positions based on Shamt5 bits
    assign ShOutA_LSR = (Shamt5[4])?{16'b0,ShIn[31:16]}:ShIn;
    assign ShOutB_LSR = (Shamt5[3])?{8'b0,ShOutA_LSR[31:8]}:ShOutA_LSR;
    assign ShOutC_LSR = (Shamt5[2])?{4'b0,ShOutB_LSR[31:4]}:ShOutB_LSR;
    assign ShOutD_LSR = (Shamt5[1])?{2'b0,ShOutC_LSR[31:2]}:ShOutC_LSR;
    assign ShOutLSR   = (Shamt5[0])?{1'b0,ShOutD_LSR[31:1]}:ShOutD_LSR;

    //====================================================
    // ASR - Arithmetic Shift Right (sign extension)
    //====================================================
    // Shift by 16, 8, 4, 2, 1 positions based on Shamt5 bits, preserving sign bit
    assign ShOutA_ASR = (Shamt5[4])?{ShIn[31],{15{ShIn[31]}},ShIn[31:16]}:ShIn;
    assign ShOutB_ASR = (Shamt5[3])?{ShIn[31],{7{ShIn[31]}},ShOutA_ASR[31:8]}:ShOutA_ASR;
    assign ShOutC_ASR = (Shamt5[2])?{ShIn[31],{3{ShIn[31]}},ShOutB_ASR[31:4]}:ShOutB_ASR;
    assign ShOutD_ASR = (Shamt5[1])?{ShIn[31],{1{ShIn[31]}},ShOutC_ASR[31:2]}:ShOutC_ASR;
    assign ShOutASR   = (Shamt5[0])?{ShIn[31],ShOutD_ASR[31:1]}:ShOutD_ASR;

    //====================================================
    // ROR - Rotate Right
    //====================================================
    // Rotate by 16, 8, 4, 2, 1 positions based on Shamt5 bits
    assign ShOutA_ROR = (Shamt5[4])?{ShIn[15:0],ShIn[31:16]}:ShIn;
    assign ShOutB_ROR = (Shamt5[3])?{ShOutA_ROR[7:0],ShOutA_ROR[31:8]}:ShOutA_ROR;
    assign ShOutC_ROR = (Shamt5[2])?{ShOutB_ROR[3:0],ShOutB_ROR[31:4]}:ShOutB_ROR;
    assign ShOutD_ROR = (Shamt5[1])?{ShOutC_ROR[1:0],ShOutC_ROR[31:2]}:ShOutC_ROR;
    assign ShOutROR   = (Shamt5[0])?{ShOutD_ROR[0],ShOutD_ROR[31:1]}:ShOutD_ROR;

    //====================================================
    // Shift Type Selection
    //====================================================
    always@(*)begin
        case(Sh)
            2'b00: ShOut_r=ShOutLSL;  // Logical Shift Left
            2'b01: ShOut_r=ShOutLSR;  // Logical Shift Right
            2'b10: ShOut_r=ShOutASR;  // Arithmetic Shift Right
            2'b11: ShOut_r=ShOutROR;  // Rotate Right
        endcase
    end

    assign ShOut=ShOut_r;

endmodule 
