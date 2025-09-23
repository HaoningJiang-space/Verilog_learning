`timescale 1ns / 1ps

`define IDLE   3'b000
`define FETCHA 3'b001
`define FETCHB 3'b010
`define EXECA  3'b011
`define EXECB  3'b100

module state(
    input clk,
    input reset,   // active low reset (reset == 0 -> go to IDLE)
    input run,
    input cont,
    input halt,
    output [2:0] cs
);

reg [2:0] cs_reg;
assign cs = cs_reg;

always @(posedge clk or negedge reset) begin
    if (!reset)
        cs_reg <= `IDLE;
    else begin
        case (cs_reg)
            `IDLE:   if (run)        cs_reg <= `FETCHA;
                     else            cs_reg <= `IDLE;
            `FETCHA:                 cs_reg <= `FETCHB;
            `FETCHB:                 cs_reg <= `EXECA;
            `EXECA:  if (halt)       cs_reg <= `IDLE;
                     else if (cont)  cs_reg <= `EXECB;
                     else            cs_reg <= `FETCHA;
            `EXECB:                  cs_reg <= `FETCHA;
            default:                 cs_reg <= 3'bxxx;
        endcase
    end
end

endmodule