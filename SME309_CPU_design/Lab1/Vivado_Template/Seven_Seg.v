`timescale 1ns / 1ps

module Seven_Seg(
    input clk,              // fundamental frequency 100MHz (in Xilinx Board) 50MHZ (in Pango board)
    input [31:0] data,      // 32-bit MEM contents willing to display on 7-segments
    output [7:0] anode,     // anodes for 7-segments
    output          dp,     // dot point for 7-segments
    output [6:0] cathode    // cathodes for 7-segments
);

// Counter for display multiplexing (refresh rate control)
reg [19:0] refresh_counter; // ~1ms refresh rate at 100MHz
wire [2:0] digit_select;

// Extract current digit from refresh counter
assign digit_select = refresh_counter[19:17]; // Use upper 3 bits for digit selection

// Current digit value (4-bit hex)
reg [3:0] digit_value;

// Select which 4-bit digit to display based on digit_select
always @(*) begin
    case (digit_select)
        3'b000: digit_value = data[3:0];    // LSB digit
        3'b001: digit_value = data[7:4];
        3'b010: digit_value = data[11:8];
        3'b011: digit_value = data[15:12];
        3'b100: digit_value = data[19:16];
        3'b101: digit_value = data[23:20];
        3'b110: digit_value = data[27:24];
        3'b111: digit_value = data[31:28];  // MSB digit
        default: digit_value = 4'h0;
    endcase
end

// Anode control (active low) - only one digit active at a time
reg [7:0] anode_reg;
always @(*) begin
    case (digit_select)
        3'b000: anode_reg = 8'b11111110; // Activate rightmost digit
        3'b001: anode_reg = 8'b11111101;
        3'b010: anode_reg = 8'b11111011;
        3'b011: anode_reg = 8'b11110111;
        3'b100: anode_reg = 8'b11101111;
        3'b101: anode_reg = 8'b11011111;
        3'b110: anode_reg = 8'b10111111;
        3'b111: anode_reg = 8'b01111111; // Activate leftmost digit
        default: anode_reg = 8'b11111111; // All off
    endcase
end

assign anode = anode_reg;

// 7-segment decoder (cathode control, active low)
reg [6:0] cathode_reg;
always @(*) begin
    case (digit_value)
        4'h0: cathode_reg = 7'b1000000; // 0
        4'h1: cathode_reg = 7'b1111001; // 1
        4'h2: cathode_reg = 7'b0100100; // 2
        4'h3: cathode_reg = 7'b0110000; // 3
        4'h4: cathode_reg = 7'b0011001; // 4
        4'h5: cathode_reg = 7'b0010010; // 5
        4'h6: cathode_reg = 7'b0000010; // 6
        4'h7: cathode_reg = 7'b1111000; // 7
        4'h8: cathode_reg = 7'b0000000; // 8
        4'h9: cathode_reg = 7'b0010000; // 9
        4'hA: cathode_reg = 7'b0001000; // A
        4'hB: cathode_reg = 7'b0000011; // b
        4'hC: cathode_reg = 7'b1000110; // C
        4'hD: cathode_reg = 7'b0100001; // d
        4'hE: cathode_reg = 7'b0000110; // E
        4'hF: cathode_reg = 7'b0001110; // F
        default: cathode_reg = 7'b1111111; // All segments off
    endcase
end

assign cathode = cathode_reg;

// Dot point control (usually off for this application)
assign dp = 1'b1; // Active low, so 1 means off

// Refresh counter
always @(posedge clk) begin
    refresh_counter <= refresh_counter + 1;
end

// Initialize
initial begin
    refresh_counter = 0;
end

endmodule
