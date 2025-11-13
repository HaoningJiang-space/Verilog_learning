`timescale 1ns/1ps
module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output [31:0] ShOut
    );

     // 00: LSL, 01: LSR, 10: ASR, 11: ROR
     reg [31:0] r;
     always @(*) begin
        case (Sh)
            2'b00: r = ShIn << Shamt5;
            2'b01: r = ShIn >> Shamt5;
            2'b10: r = $signed(ShIn) >>> Shamt5;
            default: begin
                if (Shamt5 == 0)
                    r = ShIn;
                else
                    r = (ShIn >> Shamt5) | (ShIn << (32 - Shamt5));
            end
        endcase
     end

     assign ShOut = r;
     
endmodule 
