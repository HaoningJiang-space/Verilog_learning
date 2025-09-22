`timescale 1ns / 1ps

module mem(
    input clk,
    input [7:0] addr,
    output reg [31:0] data
);

// Memory arrays - using addr[7] to select between instruction and data memory
// addr[6:0] for actual memory address (128 locations each)
reg [31:0] instr_mem [0:127];  // Instruction ROM
reg [31:0] data_mem [0:127];   // Data ROM

// Memory read operation
always @(posedge clk) begin
    if (addr[7] == 0) begin
        // Access instruction memory when addr[7] = 0
        data <= instr_mem[addr[6:0]];
    end else begin
        // Access data memory when addr[7] = 1
        data <= data_mem[addr[6:0]];
    end
end

// Initialize instruction memory
initial begin
    integer i;  // 将变量声明移到块的开始

    // Real instruction data from .s file
    instr_mem[0]  = 32'hE3A00000;  // MOV instruction
    instr_mem[1]  = 32'hE1A0100F;  // MOV instruction
    instr_mem[2]  = 32'hE0800001;  // ADD instruction
    instr_mem[3]  = 32'hE2511001;  // SUBS instruction
    instr_mem[4]  = 32'h1AFFFFFC;  // BNE instruction
    instr_mem[5]  = 32'hE59F01E8;  // LDR instruction
    instr_mem[6]  = 32'hE58F57E0;  // STR instruction
    instr_mem[7]  = 32'hE59F57DC;  // LDR instruction
    instr_mem[8]  = 32'hE59F21D8;  // LDR instruction
    instr_mem[9]  = 32'hE5820000;  // STR instruction
    instr_mem[10] = 32'hE5820004;  // STR instruction
    instr_mem[11] = 32'hEAFFFFFE;  // B instruction (infinite loop)

    // Initialize remaining instruction memory to zero
    for (i = 12; i < 128; i = i + 1) begin
        instr_mem[i] = 32'h0;
    end
end

// Initialize data memory
initial begin
    integer j;  // 将变量声明移到块的开始

    // Real data from .s file
    data_mem[0] = 32'h00000800;  // Data constant 1
    data_mem[1] = 32'hABCD1234;  // Data constant 2

    // Initialize remaining data memory to zero as required
    for (j = 2; j < 128; j = j + 1) begin
        data_mem[j] = 32'h00000000;
    end
end

endmodule
