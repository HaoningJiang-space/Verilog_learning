`timescale 1ns/1ps
module Decoder(
    input [31:0] Instr,
	
    output PCS,
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW
    ); 
    
    // Extract fields
    wire [1:0] op    = Instr[27:26];
    wire       I     = Instr[25];
    wire       L     = Instr[20];
    wire [3:0] funct = Instr[24:21];
    wire       S     = Instr[20];

    // Internal regs to drive wire outputs
    reg PCS_d;
    reg RegW_d;
    reg MemW_d;
    reg MemtoReg_d;
    reg ALUSrc_d;
    reg [1:0] ImmSrc_d;
    reg [1:0] RegSrc_d;

    // Continuous assignments to wire outputs
    assign PCS      = PCS_d;
    assign RegW     = RegW_d;
    assign MemW     = MemW_d;
    assign MemtoReg = MemtoReg_d;
    assign ALUSrc   = ALUSrc_d;
    assign ImmSrc   = ImmSrc_d;
    assign RegSrc   = RegSrc_d;

    // Main decoder using case on op (avoid driving 'x to outputs to reduce X-propagation in sim)
    always @(*) begin
        // safe defaults
        PCS_d      = 1'b0;
        RegW_d     = 1'b0;
        MemW_d     = 1'b0;
        MemtoReg_d = 1'b0;
        ALUSrc_d   = 1'b0;
        ImmSrc_d   = 2'b00;
        RegSrc_d   = 2'b00;

        casex (op)
            2'b10: begin // Branch
                PCS_d    = 1'b1;      // request PC update (gated by CondLogic)
                ALUSrc_d = 1'b1;      // use immediate offset
                ImmSrc_d = 2'b10;     // branch imm type (sign-extend 24<<2)
                RegSrc_d = 2'b01;     // A1<=R15
            end
            2'b01: begin // LDR/STR
                MemtoReg_d = L;       // LDR writes from memory
                MemW_d     = ~L;      // STR writes to memory
                RegW_d     = L;       // LDR writes back to Rt
                ALUSrc_d   = 1'b1;    // use 12-bit offset
                ImmSrc_d   = 2'b01;   // load/store immediate type
                RegSrc_d   = {~L, 1'b0}; // STR: B端选Rt
            end
            2'b00: begin // Data Processing
                // 仅当不是 TST/TEQ/CMP/CMN 才写回
                // 注意：这里用 funct[3:0]
                RegW_d   = ~(funct[3] & (~funct[1])); // 屏蔽 1000(TST)/1001(TEQ)/1010(CMP)/1011(CMN)
                ALUSrc_d = I;         // immediate or register operand2
                ImmSrc_d = 2'b00;     // DP imm（简化，不处理旋转）
            end
            default: begin
                // keep safe defaults
            end
        endcase
    end

    // ALU control with case statements; provide safe defaults when not applicable
    always @(*) begin
        ALUControl = 2'b01; // default ADD
        case (op)
            2'b10: begin // Branch
                ALUControl = 2'b01; // ADD PC + offset
            end
            2'b01: begin // LDR/STR address calc
                ALUControl = 2'b01; // ADD base + offset
            end
            2'b00: begin // DP
                // 识别“只改标志”的指令
                // funct[3:0]: AND=0000, ORR=1100, ADD=0100, SUB=0010, TST=1000, TEQ=1001, CMP=1010, CMN=1011
                case (funct[3:0])
                    4'b0000: ALUControl = 2'b00; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b0100: ALUControl = 2'b01; // ADD
                    4'b0010: ALUControl = 2'b10; // SUB
                    4'b1011: ALUControl = 2'b01; // CMN => ADD
                    4'b1000: ALUControl = 2'b00; // TST => AND
                    4'b1010: ALUControl = 2'b10; // CMP => SUB
                    default: ALUControl = 2'b01; // default ADD
                endcase
            end
            default: begin
                // keep default ADD
            end
        endcase
    end

    // Flag write enables: only DP & S=1 drives; otherwise safe 0
    always @(*) begin
        FlagW = 2'b00;
        if (op == 2'b00 && S)
            FlagW = 2'b11;
    end
   
endmodule