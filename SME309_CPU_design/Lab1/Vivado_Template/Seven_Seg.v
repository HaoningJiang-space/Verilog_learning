`timescale 1ns / 1ps

module Seven_Seg(
    input clk,              // fundamental frequency 100MHz (in Xilinx Board) 50MHZ (in Pango board)
    input [31:0] data,      // 32-bit MEM contents willing to display on 7-segments
    output [7:0] anode,     // anodes for 7-segments
    output          dp,     // dot point for 7-segments
    output [6:0] cathode    // cathodes for 7-segments
);

// TODO

endmodule
