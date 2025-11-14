//-------------------------------------------------------------
// Module: TOP
// Description: Top-level module for ARM CPU on Nexys4 FPGA
//              - Integrates Wrapper module with FPGA I/O
//              - Provides clock division
//              - Drives seven-segment display with multiplexing
//              - Connects to LEDs, DIPs, and buttons
// Note: FOR SYNTHESIS ONLY. DO NOT SIMULATE THIS
//-------------------------------------------------------------
`timescale 1ns / 1ps

module TOP#(
    parameter N_LEDs_OUT = 16,           // Number of LEDs for PC display
    parameter N_DIPs = 7,                // Number of DIP switches
    parameter N_SEVEN_SEG_DIGITs = 8,    // Number of 7-segment digits
    parameter CLK_DIV_BITS = 25          // Clock divider bits (25 for ~3Hz, 0 for 100MHz)
)
(
    input  [N_DIPs-1:0] DIP,                     // DIP switches for memory address
    output [N_LEDs_OUT-1:0] LED,                 // LEDs for PC display
    output reg [N_SEVEN_SEG_DIGITs-1:0] SevenSegAn, // 7-segment anodes (active low)
    output reg [6:0] SevenSegCat,                // 7-segment cathodes
    input PAUSE,                                 // Pause button (BTNU)
    input RESET,                                 // Reset button (BTND)
    input CLK_undiv                              // 100MHz clock input
);

//-------------------------------------------------------------
// PARAMETER
//-------------------------------------------------------------
    // Clock divider: CLK_DIV_BITS = 25 gives ~3Hz CPU clock
    // Seven-segment multiplexing: 1kHz refresh rate

//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    wire [31:0] SEVENSEGHEX;  // 32-bit data for 7-segment display
    wire CLK;                 // Divided clock for CPU	

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Wrapper Module Instantiation
    //====================================================
    Wrapper wrapper1(
        .DIP(DIP),
        .LED(LED),
        .SEVENSEGHEX(SEVENSEGHEX),
        .RESET(RESET),
        .CLK(CLK)
    );

    //====================================================
    // Clock Divider
    //====================================================
    generate
        if (CLK_DIV_BITS == 0) begin
            // No clock division, use full 100MHz
            assign CLK = CLK_undiv;
        end
        else begin
            // Clock division for slower CPU operation
            reg [CLK_DIV_BITS:0] clk_counter;
            always @(posedge CLK_undiv or posedge RESET) begin
                if(RESET)
                    clk_counter <= 'b0;
                else if(~PAUSE)
                    clk_counter <= clk_counter + 1;
            end
            assign CLK = clk_counter[CLK_DIV_BITS];
        end
    endgenerate

    //====================================================
    // Seven-Segment Display Controller
    //====================================================
    reg [7:0] enable;          // Multiplexing enable (active HIGH)
    reg [3:0] data_disp;       // 4-bit display data (0-F)
    reg [16:0] count_fast;     // Counter for 1kHz multiplexing
    reg seven_seg_enable;      // 1kHz enable signal

    // Generate 1kHz enable signal for multiplexing
    always @(posedge CLK_undiv or posedge RESET) begin
        if(RESET) begin
            count_fast <= 17'b0;
            seven_seg_enable <= 1'b0;
        end
        else begin
            count_fast <= count_fast + 1;
            if(count_fast == 17'h1869F) begin  // Count to 99,999 for 1kHz (100MHz/100,000)
                seven_seg_enable <= 1'b1;
                count_fast <= 17'b0;
            end
            else
                seven_seg_enable <= 0;
        end
    end

    // Multiplex through 8 seven-segment digits
    always @(posedge CLK_undiv or posedge RESET) begin
        if(RESET) begin
            enable <= 8'b00000001;
            SevenSegAn <= 8'hff;
        end
        else begin
            if(seven_seg_enable) begin
                enable <= (enable == 8'h80) ? 8'h01 : (enable << 1);
                SevenSegAn <= ~enable;  // Anodes are active LOW
            end
        end
    end

    // Select which nibble to display and decode to 7-segment
    always @ (*) begin
        // Select 4-bit nibble based on active digit
        case (SevenSegAn)
            8'b11111110 : data_disp = SEVENSEGHEX[3:0];
            8'b11111101 : data_disp = SEVENSEGHEX[7:4];
            8'b11111011 : data_disp = SEVENSEGHEX[11:8];
            8'b11110111 : data_disp = SEVENSEGHEX[15:12];
            8'b11101111 : data_disp = SEVENSEGHEX[19:16];
            8'b11011111 : data_disp = SEVENSEGHEX[23:20];
            8'b10111111 : data_disp = SEVENSEGHEX[27:24];
            8'b01111111 : data_disp = SEVENSEGHEX[31:28];
            default : data_disp = 4'h0;
        endcase

        // Decode 4-bit value to 7-segment cathodes (active LOW)
        case (data_disp)
            4'h0 : SevenSegCat = 7'b1000000;  // 0
            4'h1 : SevenSegCat = 7'b1111001;  // 1
            4'h2 : SevenSegCat = 7'b0100100;  // 2
            4'h3 : SevenSegCat = 7'b0110000;  // 3
            4'h4 : SevenSegCat = 7'b0011001;  // 4
            4'h5 : SevenSegCat = 7'b0010010;  // 5
            4'h6 : SevenSegCat = 7'b0000010;  // 6
            4'h7 : SevenSegCat = 7'b1111000;  // 7
            4'h8 : SevenSegCat = 7'b0000000;  // 8
            4'h9 : SevenSegCat = 7'b0010000;  // 9
            4'hA : SevenSegCat = 7'b0001000;  // A
            4'hB : SevenSegCat = 7'b0000011;  // B
            4'hC : SevenSegCat = 7'b1000110;  // C
            4'hD : SevenSegCat = 7'b0100001;  // D
            4'hE : SevenSegCat = 7'b0000110;  // E
            4'hF : SevenSegCat = 7'b0001110;  // F
        endcase
    end

endmodule