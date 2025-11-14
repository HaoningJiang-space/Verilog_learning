//-------------------------------------------------------------
// Module: RegisterFile
// Description: Register File for ARM CPU
//              - 15 general-purpose registers (R0-R14)
//              - R15 (PC) is handled separately
//              - Dual-port read, single-port write
//-------------------------------------------------------------
module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] A1,
    input [3:0] A2,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,

    output [31:0] RD1,
    output [31:0] RD2
);

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    // Register bank: R0-R14 (R15/PC is handled separately)
    reg [31:0] RegBank[0:14];

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Register Write Logic (Sequential)
    //====================================================
    always@(posedge CLK)begin
        if(WE3)begin
            RegBank[A3]<=WD3;
        end
    end

    //====================================================
    // Register Read Logic (Combinational)
    //====================================================
    // R15 is the Program Counter, handled separately
    // For single-cycle CPU, read and write happen in the same cycle
    assign RD1 = (A1==4'b1111) ? R15 : RegBank[A1]; //  // 如果地址是15,返回PC;否则从RegBank读取
    assign RD2 = (A2==4'b1111) ? R15 : RegBank[A2];

endmodule