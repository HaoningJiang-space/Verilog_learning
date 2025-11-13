module Wrapper_tb;
reg [6:0] DIP;
reg RESET,CLK;
wire [15:0] LED;
wire [31:0] SEVENSEGHEX;
Wrapper wrapper1 (DIP,LED,SEVENSEGHEX,RESET,CLK); 
initial begin
  DIP = 6'b001100;
  CLK = 0;
  RESET = 0;
  #10
  RESET = 1;
  #10
  RESET = 0;
  #500
  $finish;
end
always #5 CLK = ~CLK;


initial begin
    $dumpfile("Wrapper_tb.vcd");
    $dumpvars(0, Wrapper_tb);
    $display("VCD saved to Wrapper.vcd");
end

endmodule