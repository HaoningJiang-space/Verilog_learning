//-------------------------------------------------------------
// Module: CondLogic
// Description: Conditional Execution Logic for ARM CPU
//              - Evaluates condition codes
//              - Updates condition flags (N, Z, C, V)
//              - Controls conditional execution of instructions
//-------------------------------------------------------------
module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input MemW,
    input [1:0] FlagW,
    input [3:0] Cond,
    input [3:0] ALUFlags,

    output PCSrc,
    output RegWrite,
    output MemWrite
);

//-------------------------------------------------------------
// PARAMETER
//-------------------------------------------------------------
    // Condition codes:
    // 0000: EQ (Equal)
    // 0001: NE (Not Equal)
    // 0010: CS/HS (Carry Set/Unsigned Higher or Same)
    // 0011: CC/LO (Carry Clear/Unsigned Lower)
    // 0100: MI (Minus/Negative)
    // 0101: PL (Plus/Positive or Zero)
    // 0110: VS (Overflow Set)
    // 0111: VC (Overflow Clear)
    // 1000: HI (Unsigned Higher)
    // 1001: LS (Unsigned Lower or Same)
    // 1010: GE (Signed Greater or Equal)
    // 1011: LT (Signed Less Than)
    // 1100: GT (Signed Greater Than)
    // 1101: LE (Signed Less or Equal)
    // 1110: AL (Always)

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    wire [1:0] FlagWrite;
    reg CondEx;
    reg N = 0, Z = 0, C = 0, V = 0;

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Flag Write Enable Logic
    //====================================================
    assign FlagWrite[0] = FlagW[0] & CondEx; // Only write flags if condition is met
    assign FlagWrite[1] = FlagW[1] & CondEx;

    //====================================================
    // Flag Register Update
    //====================================================
    always@(posedge CLK)begin
        if(FlagWrite[1])begin
            N <= ALUFlags[3];  // Negative flag
            Z <= ALUFlags[2];  // Zero flag
        end

        if(FlagWrite[0]) begin
            C <= ALUFlags[1];  // Carry flag
            V <= ALUFlags[0];  // Overflow flag
        end
    end

    //====================================================
    // Condition Code Evaluation
    //====================================================
    always@(*)begin
        case(Cond)
            4'b0000: CondEx = Z;              // EQ: Equal
            4'b0001: CondEx = ~Z;             // NE: Not Equal
            4'b0010: CondEx = C;              // CS/HS: Carry Set
            4'b0011: CondEx = ~C;             // CC/LO: Carry Clear
            4'b0100: CondEx = N;              // MI: Minus/Negative
            4'b0101: CondEx = ~N;             // PL: Plus/Positive
            4'b0110: CondEx = V;              // VS: Overflow Set
            4'b0111: CondEx = ~V;             // VC: Overflow Clear
            4'b1000: CondEx = C & ~Z;         // HI: Unsigned Higher
            4'b1001: CondEx = ~C | Z;         // LS: Unsigned Lower or Same
            4'b1010: CondEx = (N == V);       // GE: Signed Greater or Equal
            4'b1011: CondEx = (N != V);       // LT: Signed Less Than
            4'b1100: CondEx = (~Z) & (N == V);// GT: Signed Greater Than
            4'b1101: CondEx = Z | (N != V);   // LE: Signed Less or Equal
            4'b1110: CondEx = 1'b1;           // AL: Always
            default: CondEx = 0;
        endcase
    end

    //====================================================
    // Conditional Control Signal Generation
    //====================================================
    assign PCSrc = (PCS && CondEx) ? 1'b1 : 1'b0;    // Conditional PC update
    assign RegWrite = (RegW && CondEx) ? 1'b1 : 1'b0;// Conditional register write
    assign MemWrite = (MemW && CondEx) ? 1'b1 : 1'b0;// Conditional memory write

endmodule