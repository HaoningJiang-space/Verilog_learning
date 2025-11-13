module Decoder(
    input [31:0] Instr,
    //Sent through Control Unit
    output PCS,
    output RegW, 
    output MemW, 
    output [1:0] FlagW,

    //Sent directly to datapath
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output [1:0] ALUControl,
    output NoWrite
); 
    
    wire [1:0] ALUOp; 
    wire Branch;

    reg [1:0] ALUOp_d;
    reg Branch_d;
    reg MemtoReg_d;
    reg MemW_d;
    reg ALUSrc_d;
    reg [1:0] ImmSrc_d;
    reg RegW_d;
    reg [1:0] RegSrc_d;
    reg [1:0] FlagW_d;
    reg [1:0] ALUControl_d;
    reg NoWrite_d;

    wire [1:0] Op = Instr[27:26];
   
    // Main Decoder
    always @(*) begin
        case (Op)
            2'b00: begin // Data Processing
                if (Instr[25] == 1'b0) begin // Register Type
                    Branch_d    = 1'b0;
                    MemtoReg_d  = 1'b0;
                    MemW_d      = 1'b0;
                    ALUSrc_d    = 1'b0;
                    ImmSrc_d    = 2'b00;
                    RegW_d      = 1'b1;
                    RegSrc_d    = 2'b00;
                    ALUOp_d     = 2'b11;
                end else begin // Immediate Type
                    Branch_d    = 1'b0;
                    MemtoReg_d  = 1'b0;
                    MemW_d      = 1'b0;
                    ALUSrc_d    = 1'b1;
                    ImmSrc_d    = 2'b00;
                    RegW_d      = 1'b1;
                    RegSrc_d    = 2'b00;
                    ALUOp_d     = 2'b11;
                end
            end
            2'b01: begin // Data Transfer
                if (Instr[20] == 1'b0) begin // STR
                    Branch_d    = 1'b0;
                    MemtoReg_d  = 1'b0;
                    MemW_d      = 1'b1;
                    ALUSrc_d    = 1'b1;
                    ImmSrc_d    = 2'b01;
                    RegW_d      = 1'b0;
                    RegSrc_d    = 2'b10;
                    ALUOp_d     = Instr[23] ? 2'b10 : 2'b00;
                end else begin // LDR
                    Branch_d    = 1'b0;
                    MemtoReg_d  = 1'b1;
                    MemW_d      = 1'b0;
                    ALUSrc_d    = 1'b1;
                    ImmSrc_d    = 2'b01;
                    RegW_d      = 1'b1;
                    RegSrc_d    = 2'b00;
                    ALUOp_d     = Instr[23] ? 2'b10 : 2'b00;
                end
            end
            2'b10: begin // Branch
                Branch_d    = 1'b1;
                MemtoReg_d  = 1'b0;
                MemW_d      = 1'b0;
                ALUSrc_d    = 1'b1;
                ImmSrc_d    = 2'b10;
                RegW_d      = 1'b0;
                RegSrc_d    = 2'b01;
                ALUOp_d     = 2'b10;
            end
            default: begin // Default case
                Branch_d    = 1'b0;
                MemtoReg_d  = 1'b0;
                MemW_d      = 1'b0;
                ALUSrc_d    = 1'b0;
                ImmSrc_d    = 2'b00;
                RegW_d      = 1'b0;
                RegSrc_d    = 2'b00;
                ALUOp_d     = 2'b00;
            end
        endcase
    end

    // ALU Decoder
    always @(*) begin
        if (ALUOp[0] == 1'b0) begin
            if (ALUOp[1] == 1'b0) begin 
                ALUControl_d = 2'b01; // ADD
                FlagW_d      = 2'b00; 
            end else begin
                ALUControl_d = 2'b00;
                FlagW_d      = 2'b00;
            end
        end else if (ALUOp[0] == 1'b1 && ALUOp[1] == 1'b1) begin // Data Process
            case (Instr[24:21])
                4'b0100: begin // ADD
                    FlagW_d      = Instr[20] ? 2'b11 : 2'b00;
                    ALUControl_d = 2'b00;
                    NoWrite_d    = 1'b0;
                end
                4'b0010: begin // SUB
                    FlagW_d      = Instr[20] ? 2'b11 : 2'b00;
                    ALUControl_d = 2'b01;
                    NoWrite_d    = 1'b0;
                end
                4'b0000: begin // AND
                    FlagW_d      = Instr[20] ? 2'b10 : 2'b00;
                    ALUControl_d = 2'b10;
                    NoWrite_d    = 1'b0;
                end
                4'b1100: begin // ORR
                    FlagW_d      = Instr[20] ? 2'b10 : 2'b00;
                    ALUControl_d = 2'b11;
                    NoWrite_d    = 1'b0;
                end
                4'b1010: begin // CMP
                    if (Instr[20]) begin
                        FlagW_d      = 2'b11;
                        ALUControl_d = 2'b01;
                        NoWrite_d    = 1'b1;
                    end
                end
                4'b1011: begin // CMN
                    if (Instr[20]) begin
                        FlagW_d      = 2'b11;
                        ALUControl_d = 2'b00;
                        NoWrite_d    = 1'b1;
                    end
                end
                default: begin
                    FlagW_d      = 2'b00;
                    ALUControl_d = 2'b00;
                    NoWrite_d    = 1'b0;
                end
            endcase
        end
    end

    // PC Logic
    assign PCS = (((Instr[15:12] == 4'b1111) && (RegW == 1'b1)) || (Branch == 1'b1)) ? 1'b1 : 1'b0;

    assign ALUOp      = ALUOp_d;
    assign Branch     = Branch_d;
    assign MemtoReg   = MemtoReg_d;
    assign MemW       = MemW_d;
    assign ALUSrc     = ALUSrc_d;
    assign ImmSrc     = ImmSrc_d;
    assign RegW       = RegW_d;
    assign RegSrc     = RegSrc_d;
    assign FlagW      = FlagW_d;
    assign ALUControl = ALUControl_d;
    assign NoWrite    = NoWrite_d;

endmodule