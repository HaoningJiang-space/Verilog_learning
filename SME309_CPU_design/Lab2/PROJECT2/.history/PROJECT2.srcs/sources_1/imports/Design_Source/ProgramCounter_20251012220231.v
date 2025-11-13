`timescale 1ns/1ps
module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,
    
    output reg [31:0] PC,
    output [31:0] PC_Plus_4
); 

// Clean PC logic
wire [31:0] next_pc;
wire [31:0] PC_Plus_4_output;

assign PC_Plus_4_output = PC + 32'd4;
assign next_pc = PCSrc ? Result : PC_Plus_4_output;
assign PC_Plus_4 = PC_Plus_4_output;

// initialize for simulation clarity (matches reset state)
initial PC = 32'b0;

always @(posedge CLK or posedge Reset) begin
    if (Reset)
        PC <= 32'b0;
    else
        PC <= next_pc;
end

endmodule