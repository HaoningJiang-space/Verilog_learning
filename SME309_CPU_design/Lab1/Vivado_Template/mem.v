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

// Memory read operation - 异步读取
always @(*) begin
    if (addr[7] == 0) begin
        // Access instruction memory when addr[7] = 0
        data = instr_mem[addr[6:0]];
    end else begin
        // Access data memory when addr[7] = 1
        data = data_mem[addr[6:0]];
    end
end



//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE3A00000; 
			INSTR_MEM[1] = 32'hE1A0100F; 
			INSTR_MEM[2] = 32'hE0800001; 
			INSTR_MEM[3] = 32'hE2511001; 
			INSTR_MEM[4] = 32'h1AFFFFFC; 
			INSTR_MEM[5] = 32'hE59F01E8; 
			INSTR_MEM[6] = 32'hE58F57E0; 
			INSTR_MEM[7] = 32'hE59F57DC; 
			INSTR_MEM[8] = 32'hE59F21D8; 
			INSTR_MEM[9] = 32'hE5820000; 
			INSTR_MEM[10] = 32'hE5820004; 
			INSTR_MEM[11] = 32'hE0800001; 
			INSTR_MEM[12] = 32'hE2511001; 
			INSTR_MEM[13] = 32'h1AFFFFFC; 
			INSTR_MEM[14] = 32'hE59F01C4; 
			INSTR_MEM[15] = 32'hE58F57BC; 
			INSTR_MEM[16] = 32'hE59F57B8; 
			INSTR_MEM[17] = 32'hE59F21B4; 
			INSTR_MEM[18] = 32'hE5820000; 
			INSTR_MEM[19] = 32'hE5820004; 
			INSTR_MEM[20] = 32'hE0800001; 
			INSTR_MEM[21] = 32'hE2511001; 
			INSTR_MEM[22] = 32'h1AFFFFFC; 
			INSTR_MEM[23] = 32'hE59F01A0; 
			INSTR_MEM[24] = 32'hE58F5798; 
			INSTR_MEM[25] = 32'hE59F5794; 
			INSTR_MEM[26] = 32'hE59F2190; 
			INSTR_MEM[27] = 32'hE5820000; 
			INSTR_MEM[28] = 32'hE5820004; 
			INSTR_MEM[29] = 32'hE0800001; 
			INSTR_MEM[30] = 32'hE2511001; 
			INSTR_MEM[31] = 32'h1AFFFFFC; 
			INSTR_MEM[32] = 32'hE59F017C; 
			INSTR_MEM[33] = 32'hE58F5774; 
			INSTR_MEM[34] = 32'hE59F5770; 
			INSTR_MEM[35] = 32'hE59F216C; 
			INSTR_MEM[36] = 32'hE5820000; 
			INSTR_MEM[37] = 32'hE5820004; 
			INSTR_MEM[38] = 32'hE0800001; 
			INSTR_MEM[39] = 32'hE2511001; 
			INSTR_MEM[40] = 32'h1AFFFFFC; 
			INSTR_MEM[41] = 32'hE59F0158; 
			INSTR_MEM[42] = 32'hE58F5750; 
			INSTR_MEM[43] = 32'hE59F574C; 
			INSTR_MEM[44] = 32'hE59F2148; 
			INSTR_MEM[45] = 32'hE5820000; 
			INSTR_MEM[46] = 32'hE5820004; 
			INSTR_MEM[47] = 32'hEAFFFFFE; 
			for(i = 48; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

//----------------------------------------------------------------
// Data (Constant) Memory
//----------------------------------------------------------------
initial begin
			DATA_CONST_MEM[0] = 32'h00000800; 
			DATA_CONST_MEM[1] = 32'hABCD1234; 
			DATA_CONST_MEM[2] = 32'h00000001; 
			DATA_CONST_MEM[3] = 32'h00000010; 
			DATA_CONST_MEM[4] = 32'h00000100; 
			DATA_CONST_MEM[5] = 32'h00001000; 
			DATA_CONST_MEM[6] = 32'h00010000; 
			DATA_CONST_MEM[7] = 32'h00100000; 
			DATA_CONST_MEM[8] = 32'h01000000; 
			DATA_CONST_MEM[9] = 32'h10000000; 
			DATA_CONST_MEM[10] = 32'h01000000; 
			DATA_CONST_MEM[11] = 32'h00100000; 
			DATA_CONST_MEM[12] = 32'h00010000; 
			DATA_CONST_MEM[13] = 32'h00001000; 
			DATA_CONST_MEM[14] = 32'h00000100; 
			DATA_CONST_MEM[15] = 32'h00000010; 
			DATA_CONST_MEM[16] = 32'h00000001; 
			DATA_CONST_MEM[17] = 32'h00000002; 
			DATA_CONST_MEM[18] = 32'h00000020; 
			DATA_CONST_MEM[19] = 32'h00000200; 
			DATA_CONST_MEM[20] = 32'h00002000; 
			DATA_CONST_MEM[21] = 32'h00020000; 
			DATA_CONST_MEM[22] = 32'h00200000; 
			DATA_CONST_MEM[23] = 32'h02000000; 
			DATA_CONST_MEM[24] = 32'h20000000; 
			DATA_CONST_MEM[25] = 32'h02000000; 
			DATA_CONST_MEM[26] = 32'h00200000; 
			DATA_CONST_MEM[27] = 32'h00020000; 
			DATA_CONST_MEM[28] = 32'h00002000; 
			DATA_CONST_MEM[29] = 32'h00000200; 
			DATA_CONST_MEM[30] = 32'h00000020; 
			DATA_CONST_MEM[31] = 32'h00000002; 
			DATA_CONST_MEM[32] = 32'h00000003; 
			DATA_CONST_MEM[33] = 32'h00000030; 
			DATA_CONST_MEM[34] = 32'h00000300; 
			DATA_CONST_MEM[35] = 32'h00003000; 
			DATA_CONST_MEM[36] = 32'h00030000; 
			DATA_CONST_MEM[37] = 32'h00300000; 
			DATA_CONST_MEM[38] = 32'h03000000; 
			DATA_CONST_MEM[39] = 32'h30000000; 
			DATA_CONST_MEM[40] = 32'h03000000; 
			DATA_CONST_MEM[41] = 32'h00300000; 
			DATA_CONST_MEM[42] = 32'h00030000; 
			DATA_CONST_MEM[43] = 32'h00003000; 
			DATA_CONST_MEM[44] = 32'h00000300; 
			DATA_CONST_MEM[45] = 32'h00000030; 
			DATA_CONST_MEM[46] = 32'h00000003; 
			DATA_CONST_MEM[47] = 32'h00000004; 
			DATA_CONST_MEM[48] = 32'h00000040; 
			DATA_CONST_MEM[49] = 32'h00000400; 
			DATA_CONST_MEM[50] = 32'h00004000; 
			DATA_CONST_MEM[51] = 32'h00040000; 
			DATA_CONST_MEM[52] = 32'h00400000; 
			DATA_CONST_MEM[53] = 32'h04000000; 
			DATA_CONST_MEM[54] = 32'h40000000; 
			DATA_CONST_MEM[55] = 32'h04000000; 
			DATA_CONST_MEM[56] = 32'h00400000; 
			DATA_CONST_MEM[57] = 32'h00040000; 
			DATA_CONST_MEM[58] = 32'h00004000; 
			DATA_CONST_MEM[59] = 32'h00000400; 
			DATA_CONST_MEM[60] = 32'h00000040; 
			DATA_CONST_MEM[61] = 32'h00000004; 
			DATA_CONST_MEM[62] = 32'h00000005; 
			DATA_CONST_MEM[63] = 32'h00000050; 
			DATA_CONST_MEM[64] = 32'h00000500; 
			DATA_CONST_MEM[65] = 32'h00005000; 
			DATA_CONST_MEM[66] = 32'h00050000; 
			DATA_CONST_MEM[67] = 32'h00500000; 
			DATA_CONST_MEM[68] = 32'h05000000; 
			DATA_CONST_MEM[69] = 32'h50000000; 
			DATA_CONST_MEM[70] = 32'h05000000; 
			DATA_CONST_MEM[71] = 32'h00500000; 
			DATA_CONST_MEM[72] = 32'h00050000; 
			DATA_CONST_MEM[73] = 32'h00005000; 
			DATA_CONST_MEM[74] = 32'h00000500; 
			DATA_CONST_MEM[75] = 32'h00000050; 
			DATA_CONST_MEM[76] = 32'h00000005; 
			DATA_CONST_MEM[77] = 32'h00000006; 
			DATA_CONST_MEM[78] = 32'h00000060; 
			DATA_CONST_MEM[79] = 32'h00000600; 
			DATA_CONST_MEM[80] = 32'h00006000; 
			DATA_CONST_MEM[81] = 32'h00060000; 
			DATA_CONST_MEM[82] = 32'h00600000; 
			DATA_CONST_MEM[83] = 32'h06000000; 
			DATA_CONST_MEM[84] = 32'h60000000; 
			DATA_CONST_MEM[85] = 32'h06000000; 
			DATA_CONST_MEM[86] = 32'h00600000; 
			DATA_CONST_MEM[87] = 32'h00060000; 
			DATA_CONST_MEM[88] = 32'h00006000; 
			DATA_CONST_MEM[89] = 32'h00000600; 
			DATA_CONST_MEM[90] = 32'h00000060; 
			DATA_CONST_MEM[91] = 32'h00000006; 
			DATA_CONST_MEM[92] = 32'h00000007; 
			DATA_CONST_MEM[93] = 32'h00000070; 
			DATA_CONST_MEM[94] = 32'h00000700; 
			DATA_CONST_MEM[95] = 32'h00007000; 
			DATA_CONST_MEM[96] = 32'h00070000; 
			DATA_CONST_MEM[97] = 32'h00700000; 
			DATA_CONST_MEM[98] = 32'h07000000; 
			DATA_CONST_MEM[99] = 32'h70000000; 
			DATA_CONST_MEM[100] = 32'h07000000; 
			DATA_CONST_MEM[101] = 32'h00700000; 
			DATA_CONST_MEM[102] = 32'h00070000; 
			DATA_CONST_MEM[103] = 32'h00007000; 
			DATA_CONST_MEM[104] = 32'h00000700; 
			DATA_CONST_MEM[105] = 32'h00000070; 
			DATA_CONST_MEM[106] = 32'h00000007; 
			DATA_CONST_MEM[107] = 32'h00000008; 
			DATA_CONST_MEM[108] = 32'h00000080; 
			DATA_CONST_MEM[109] = 32'h00000800; 
			DATA_CONST_MEM[110] = 32'h00008000; 
			DATA_CONST_MEM[111] = 32'h00080000; 
			DATA_CONST_MEM[112] = 32'h00800000; 
			DATA_CONST_MEM[113] = 32'h08000000; 
			DATA_CONST_MEM[114] = 32'h80000000; 
			DATA_CONST_MEM[115] = 32'h08000000; 
			DATA_CONST_MEM[116] = 32'h00800000; 
			DATA_CONST_MEM[117] = 32'h00080000; 
			DATA_CONST_MEM[118] = 32'h00008000; 
			DATA_CONST_MEM[119] = 32'h00000800; 
			DATA_CONST_MEM[120] = 32'h00000080; 
			DATA_CONST_MEM[121] = 32'h00000008; 
			for(i = 122; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end


// // Initialize instruction memory
// initial begin : init_instr_mem
//     integer i;

//     // Real instruction data from .s file
//     instr_mem[0]  = 32'hE3A00000;  // MOV instruction
//     instr_mem[1]  = 32'hE1A0100F;  // MOV instruction
//     instr_mem[2]  = 32'hE0800001;  // ADD instruction
//     instr_mem[3]  = 32'hE2511001;  // SUBS instruction
//     instr_mem[4]  = 32'h1AFFFFFC;  // BNE instruction
//     instr_mem[5]  = 32'hE59F01E8;  // LDR instruction
//     instr_mem[6]  = 32'hE58F57E0;  // STR instruction
//     instr_mem[7]  = 32'hE59F57DC;  // LDR instruction
//     instr_mem[8]  = 32'hE59F21D8;  // LDR instruction
//     instr_mem[9]  = 32'hE5820000;  // STR instruction
//     instr_mem[10] = 32'hE5820004;  // STR instruction
//     instr_mem[11] = 32'hEAFFFFFE;  // B instruction (infinite loop)

//     // Initialize remaining instruction memory to zero
//     for (i = 12; i < 128; i = i + 1) begin
//         instr_mem[i] = 32'h0;
//     end
// end

// // Initialize data memory
// initial begin : init_data_mem
//     integer j;

//     // Real data from .s file
//     data_mem[0] = 32'h00000800;  // Data constant 1
//     data_mem[1] = 32'hABCD1234;  // Data constant 2

//     // Initialize remaining data memory to zero as required
//     for (j = 2; j < 128; j = j + 1) begin
//         data_mem[j] = 32'h00000000;
//     end
// end

endmodule
