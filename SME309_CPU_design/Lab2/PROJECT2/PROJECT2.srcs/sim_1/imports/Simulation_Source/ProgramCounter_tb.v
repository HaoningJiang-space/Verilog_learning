`timescale 1ns/1ps
`include "../Design_Source/ProgramCounter.v"

module ProgramCounter_tb;

    reg CLK, Reset, PCSrc;
    reg [31:0] Result;
    
    wire [31:0] current_PC, PC_Plus_4;

    
    initial begin
        CLK = 1'b0;
        forever #1 CLK = ~CLK;
    end

    
    initial begin
        #0  Reset = 1'b1;   // reset high enable
        #10 Reset = 1'b0;
    end

    
    initial begin
        #0  PCSrc = 1'b0;
        #80 PCSrc = 1'b1;
    end

    
    initial begin
        #0  Result = 32'h0000_0000;
        #10 Result = 32'h0000_0001;
        #10 Result = 32'h0000_0002;
        #10 Result = 32'h0000_0003;
        #10 Result = 32'h0000_0004;
        #10 Result = 32'h0000_0005;
        #10 Result = 32'h0000_0006;
        #10 Result = 32'h0000_0007;
        #10 Result = 32'h0000_0008;
        #10 Result = 32'h0000_0009;
        #10 Result = 32'h0000_000A;
        #10 Result = 32'h0000_000B;
        #10 Result = 32'h0000_000C;
        #10 Result = 32'h0000_000D;
        #10 Result = 32'h0000_000E;
        #10 Result = 32'h0000_000F;
    end

   
    ProgramCounter PC1(
        CLK,
        Reset,
        PCSrc,
        Result,
        current_PC,
        PC_Plus_4
    );

endmodule
