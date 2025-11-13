`timescale 1ns/1ps
module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] A1,
    input [3:0] A2,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,
    input [3:0] A4,              // 新增：Rs 索引

    output [31:0] RD1,
    output [31:0] RD2,
    output [31:0] RD4            // 新增：Rs 读数
    );
    
    // declare RegBank
    reg [31:0] RegBank[0:14] ;
    integer i;

    // optional: initialize to zero for simulation readability
    initial begin
        for (i = 0; i < 15; i = i + 1) begin
            RegBank[i] = 32'b0;
        end
    end

    // synchronous write on rising edge; R15 (15) is not stored in RegBank
    always @(posedge CLK) begin
        if (WE3 && (A3 != 4'd15)) begin
            RegBank[A3] <= WD3;
        end
    end

    // asynchronous read; if address is 15, return external R15 (PC)
    assign RD1 = (A1 == 4'd15) ? R15 : RegBank[A1];
    assign RD2 = (A2 == 4'd15) ? R15 : RegBank[A2];
    assign RD4 = (A4 == 4'd15) ? R15 : RegBank[A4];
 
endmodule