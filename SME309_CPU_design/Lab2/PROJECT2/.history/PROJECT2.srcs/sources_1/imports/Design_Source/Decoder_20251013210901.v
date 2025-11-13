`timescale 1ns/1ps
module Decoder(
    input  [31:0] Instr,
    output        PCS,
    output        RegW,
    output        MemW,
    output        MemtoReg,
    output        ALUSrc,
    output [1:0]  ImmSrc,
    output [1:0]  RegSrc,      // RegSrc[1]: A1 选 R15；RegSrc[0]: A2 选 Rd(STR)
    output reg [1:0] ALUControl, // 00 ADD, 01 SUB, 10 AND, 11 ORR
    output reg [1:0] FlagW       // [1]:NZ, [0]:CV
);
    // 字段
    wire [1:0] op    = Instr[27:26];
    wire       I     = Instr[25];
    wire       L     = Instr[20];
    wire [3:0] funct = Instr[24:21];
    wire       S     = Instr[20];
    wire [3:0] Rd    = Instr[15:12];

    // 内部寄存输出
    reg Branch_r, RegW_r, MemW_r, MemtoReg_r, ALUSrc_r,PCS_r;
    reg [1:0] ImmSrc_r, RegSrc_r, ALUOp_r;

    // 连到输出
    assign PCS      = PCS_r;
    assign RegW     = RegW_r;
    assign MemW     = MemW_r;
    assign MemtoReg = MemtoReg_r;
    assign ALUSrc   = ALUSrc_r;
    assign ImmSrc   = ImmSrc_r;
    assign RegSrc   = RegSrc_r;

    // ALUControl 映射（与 ALU 一致）
    always @(*) begin
        ALUControl = 2'b00;
        case (op)
            2'b10: ALUControl = 2'b00; // Branch: ADD
            2'b01: ALUControl = 2'b00; // LDR/STR: base + offset
            2'b00: begin
                case (funct)
                    4'b0100: ALUControl = 2'b00; // ADD
                    4'b0010: ALUControl = 2'b01; // SUB
                    4'b0000: ALUControl = 2'b10; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b1010: ALUControl = 2'b01; // CMP -> SUB
                    4'b1011: ALUControl = 2'b00; // CMN -> ADD
                    4'b1000: ALUControl = 2'b10; // TST -> AND
                    4'b1001: ALUControl = 2'b10; // TEQ -> AND
                    default: ALUControl = 2'b00;
                endcase
            end
        endcase
    end

    // 主译码
    always@(*)begin
        case (op)
            2'b00: begin // Data Processing (e.g., ADD, SUB, AND, OR)
            if(Instr[25]==1'b0) begin // Data Processing Register Type
                Branch_r=1'b0;
                MemtoReg_r=1'b0;
                MemW_r=1'b0;
                ALUSrc_r=1'b0;
                ImmSrc_r=2'b00; // Not used
                RegW_r=1'b1;
                RegSrc_r=2'b00; // rd
                ALUOp_r=2'b11;
            end
            else if(Instr[25]==1'b1) begin// Data Processing Immediate Type
                Branch_r=1'b0;
                MemtoReg_r=1'b0;
                MemW_r=1'b0;
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b00; // I-type
                RegW_r=1'b1;
                RegSrc_r=2'b00; // rd x0
                ALUOp_r=2'b11;
                
            end
            end
            2'b01: begin       //Data Transfer 
            if(Instr[20]==1'b0) begin // STR
               if(Instr[23]==1'b1)begin  //U=1 -> Positive Imm offset
                Branch_r=1'b0;
                MemtoReg_r=1'b0;//x
                MemW_r=1'b1; // Write to memory
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b01; // I-type
                RegW_r=1'b0;
                RegSrc_r=2'b10; // rt
                ALUOp_r=2'b10;
               end
               else if (Instr[23]==1'b0)begin//U=0 -> Negtive Imm offset
                Branch_r=1'b0;
                MemtoReg_r=1'b0;//x
                MemW_r=1'b1; // Write to memory
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b01; // I-type
                RegW_r=1'b0;
                RegSrc_r=2'b10; // rt
                ALUOp_r=2'b00;
               end
            end
            else if(Instr[20]==1'b1)begin  //LDR
              if(Instr[23]==1'b1)begin  //U=1 -> Positive Imm offset
                Branch_r=1'b0;
                MemtoReg_r=1'b1;//x
                MemW_r=1'b0; // Write to memory
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b01; // I-type
                RegW_r=1'b1;
                RegSrc_r=2'b00; // rt x0
                ALUOp_r=2'b10;
              end
              else if (Instr[23]==1'b0)begin//U=0 -> Negtive Imm offset
                Branch_r=1'b0;
                MemtoReg_r=1'b1;//x
                MemW_r=1'b0; // Write to memory
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b01; // I-type
                RegW_r=1'b1;
                RegSrc_r=2'b00; // rt x0
                ALUOp_r=2'b00;
              end
            
            end
            end
            2'b10: begin // Branch
                Branch_r=1'b1;
                MemtoReg_r=1'b0;//x
                MemW_r=1'b0; // Write to memory
                ALUSrc_r=1'b1;
                ImmSrc_r=2'b10; // I-type
                RegW_r=1'b0;
                RegSrc_r=2'b01; // rt x1
                ALUOp_r=2'b10;
            end
            
/*    2'b11: begin // Coprocessor / Software interrupt
            if(Instr[27:26]==2'b01) begin // I-type
                RegW=1'b0;
                MemW=1'b1;
                MemtoReg=1'bx; // Don't care
                ALUSrc=1'b1;
                ImmSrc=2'b00; // I-type
                RegSrc=2'bxx; // Don't care
                ALUOp=1'b0;
                FlagW=2'b00; // No flag write
                PCS=1'b0; // No PC write
            end
            else begin// Default case      --Need to be checked
                RegW=1'b0;
                MemW=1'b0;
                MemtoReg=1'b0;
                ALUSrc=1'b0;
                ImmSrc=2'b00; // Not used
                RegSrc=2'b00; // rd
                ALUOp=1'b0;
                FlagW=2'b00; // No flag write
                PCS=1'b0; // No PC write
            end
            end 
*/
            default: begin // Default case
            
            // Default case      --Need to be checked
                Branch_r=1'b0;
                MemtoReg_r=1'b0;//x
                MemW_r=1'b0; // Write to memory
                ALUSrc_r=1'b0;
                ImmSrc_r=2'b00; // I-type
                RegW_r=1'b0;
                RegSrc_r=2'b00; // rt x1
                ALUOp_r=2'b00;
            
            end
        endcase
    end
//-----------------
endmodule