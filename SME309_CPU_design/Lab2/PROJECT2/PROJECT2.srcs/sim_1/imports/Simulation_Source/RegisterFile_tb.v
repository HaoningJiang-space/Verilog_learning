`timescale 1ns/1ps
`include "../Design_Source/RegisterFile.v"

module RegisterFile_tb;

    reg CLK, WE3;
    reg [3:0] A1, A2, A3;
    reg [31:0] WD3;
    reg [31:0] R15;

    wire [31:0] RD1, RD2;

    initial begin
        CLK = 1'b0;
        forever #1 CLK = ~CLK; 
    end

    // Write enable generation and write transactions (align to posedges at t=1,3,5,...)
    initial begin
        // default
        WE3 = 1'b0; A3 = 4'd0; WD3 = 32'h0000_0000;
        
        // Write R0, R1, R2 on consecutive posedges (at t=1,3,5)
        #0  WE3 = 1'b1; A3 = 4'd0; WD3 = 32'h1111_1111; // captured at t=1
        #2  A3 = 4'd1;  WD3 = 32'h2222_2222;            // captured at t=3
        #2  A3 = 4'd2;  WD3 = 32'h3333_3333;            // captured at t=5

        // Try to write R15 (should be ignored by RF)
        #2  A3 = 4'd15; WD3 = 32'hAAAA_AAAA;            // posedge t=7 ignored
        #2  WE3 = 1'b0;                                 // stop writing after t=9
    end

    initial begin
        // Start by reading R15 and R0
        A1 = 4'd15; A2 = 4'd0;
        #10 A1 = 4'd0;  A2 = 4'd1; // should see 0x1111_1111 and 0x2222_2222
        #10 A1 = 4'd2;  A2 = 4'd15; // should see 0x3333_3333 and R15
        #10 A1 = 4'd1;  A2 = 4'd2;
        #10 A1 = 4'd15; A2 = 4'd15; // both read external R15
        #10 $finish;
    end

    initial begin
        R15 = 32'h1000_0000;
        #20 R15 = 32'h1000_0004;
        #20 R15 = 32'h1000_0008;
    end

    RegisterFile RF1(
        CLK,
        WE3,
        A1,
        A2,
        A3,
        WD3,
        R15,
        RD1,
        RD2
    );

endmodule
