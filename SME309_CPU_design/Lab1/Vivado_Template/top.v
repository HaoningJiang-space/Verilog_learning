`timescale 1ns / 1ps

module top(
    input btn_p,                // pause button
    input btn_spdup,            // speed-up button
    input btn_spddn,            // speed-down button
    input clk,                  // input clk, fundamental frequency 100MHz (in Xilinx Board) 50MHZ (in Pango board)
    output [7:0] anode,         // anodes for 7-segment
    output [6:0] cathode,       // cathodes for 7-segment
    output dp,                  // dot point for 7-segment
    output [7:0] led            // output current addr by led 
);

wire [7:0] addr;
wire [31:0] data;

control ctrl(clk, btn_p, btn_spdup, btn_spddn, addr);

Seven_Seg ss(clk, data, anode, dp, cathode);

// TODO - add others missing codes

endmodule
