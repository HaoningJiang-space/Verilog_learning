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

// Control module generates 8-bit address
// addr[7] = 0 for instruction memory, addr[7] = 1 for data memory
// addr[6:0] = actual memory address (0-127)
control ctrl(clk, btn_p, btn_spdup, btn_spddn, addr);

// Memory module contains both instruction and data ROM
// Uses addr[7] to select between them
mem memory(clk, addr, data);

// Seven-segment display shows memory content
Seven_Seg ss(clk, data, anode, dp, cathode);

// LED display shows current address
assign led = addr;

endmodule
