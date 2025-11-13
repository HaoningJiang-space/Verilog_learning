`timescale 1ns/1ps
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
    
    reg CondEx ;
    reg N = 0, Z = 0, C = 0, V = 0 ;

    // Evaluate condition
    always @(*) begin
        case (Cond)
            4'b0000: CondEx = Z;                  // EQ
            4'b0001: CondEx = ~Z;                 // NE
            4'b0010: CondEx = C;                  // CS/HS
            4'b0011: CondEx = ~C;                 // CC/LO
            4'b0100: CondEx = N;                  // MI
            4'b0101: CondEx = ~N;                 // PL
            4'b0110: CondEx = V;                  // VS
            4'b0111: CondEx = ~V;                 // VC
            4'b1000: CondEx = C & ~Z;             // HI
            4'b1001: CondEx = ~C | Z;             // LS
            4'b1010: CondEx = (N == V);           // GE
            4'b1011: CondEx = (N != V);           // LT
            4'b1100: CondEx = ~Z & (N == V);      // GT
            4'b1101: CondEx = Z | (N != V);       // LE
            4'b1110: CondEx = 1'b1;               // AL
            default: CondEx = 1'b0;               // NV
        endcase
    end

    // Latch flags according to FlagW
    always @(posedge CLK) begin
        if (FlagW[1]) begin // write NZ
            N <= ALUFlags[3];
            Z <= ALUFlags[2];
        end
        if (FlagW[0]) begin // write CV
            C <= ALUFlags[1];
            V <= ALUFlags[0];
        end
    end

    assign RegWrite = RegW & CondEx;
    assign MemWrite = MemW & CondEx;
    assign PCSrc    = PCS & CondEx;
    
endmodule