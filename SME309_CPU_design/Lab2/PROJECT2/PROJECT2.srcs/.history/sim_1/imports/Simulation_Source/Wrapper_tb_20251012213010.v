`timescale 1ns/1ps
module Wrapper_tb;
reg [6:0] DIP;
reg RESET,CLK;
wire [15:0] LED;
wire [31:0] SEVENSEGHEX;
Wrapper wrapper1 (DIP,LED,SEVENSEGHEX,RESET,CLK);

// Clock generation: 100 MHz equivalent (10ns period)
always #5 CLK = ~CLK;

// Stimulus
initial begin
  DIP   = 7'b0001100; // address to probe via SevenSeg (same as 6'b001100)
  CLK   = 1'b0;
  RESET = 1'b0;
  #10 RESET = 1'b1;   // assert reset
  #10 RESET = 1'b0;   // deassert reset
end

// Finish when PC (LED shows lower 16 bits of PC) reaches 0x00E8
initial begin
  wait (LED == 16'h00E8);
  $display("PASS: PC reached 0xE8 at time %0t", $time);
  #10 $finish;
end

// Safety timeout to avoid hanging if condition never met
initial begin
  #(2000); // 200 cycles @10ns = 2000ns, > enough for 58 cycles to reach 0xE8
  $display("TIMEOUT: PC did not reach 0xE8. Last LED=%h at time %0t", LED, $time);
  $finish;
end

endmodule