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
    
    wire [1:0]ALUOp ; 
    wire Branch ;

    reg [1:0]ALUOp_r;
    reg Branch_r;
    reg MemtoReg_r;
    reg MemW_r;
    reg ALUSrc_r;
    reg [1:0] ImmSrc_r;
    reg RegW_r;
    reg [1:0] RegSrc_r;
    reg [1:0] FlagW_r;
    reg [1:0] ALUControl_r;
    reg NoWrite_r;

    // 字段
    wire [1:0] Op    = Instr[27:26];
    wire       I     = Instr[25];
    wire       L     = Instr[20];
    wire [3:0] funct = Instr[24:21];
    wire [3:0] Rd    = Instr[15:12];

    //-----------------    
    // Main Decoder
    //-----------------
    always @(*) begin
        // 默认值
        Branch_r   = 1'b0;
        MemtoReg_r = 1'b0;
        MemW_r     = 1'b0;
        ALUSrc_r   = 1'b0;
        ImmSrc_r   = 2'b00;
        RegW_r     = 1'b0;
        RegSrc_r   = 2'b00;
        ALUOp_r    = 2'b00;

        case (Op)
            2'b00: begin // Data Processing
                ALUSrc_r   = I;        // I=1 取立即数
                ImmSrc_r   = 2'b00;    // DP 立即数
                RegW_r     = 1'b1;     // 先假定写回，DP 解码里修正
                RegSrc_r   = 2'b00;    // A1=Rn, A2=Rm
                ALUOp_r    = 2'b11;    // 标示为数据处理
            end
            2'b01: begin // LDR/STR
                MemtoReg_r = L;        // LDR:1, STR:0
                MemW_r     = ~L;       // STR:1
                ALUSrc_r   = 1'b1;     // 基址 + 立即数
                ImmSrc_r   = 2'b01;    // 12-bit 偏移
                RegW_r     = L;        // 仅 LDR 写回
                RegSrc_r   = {1'b0, ~L}; // STR 时 A2=Rd
                ALUOp_r    = 2'b10;    // 地址类
            end
            2'b10: begin // Branch
                Branch_r   = 1'b1;
                ALUSrc_r   = 1'b1;
                ImmSrc_r   = 2'b10;    // 分支偏移
                RegW_r     = 1'b0;
                RegSrc_r   = 2'b10;    // A1=R15
                ALUOp_r    = 2'b10;    // 地址类
            end
            default: ; // 保持默认
        endcase
    end

    //-----------------
    // ALU Decoder
    //-----------------
    always @(*) begin
        // 默认，防止保持
        ALUControl_r = 2'b00;
        FlagW_r      = 2'b00;
        NoWrite_r    = 1'b0;

        if (ALUOp[0]==1'b0) begin
            // 非数据处理（访存/分支）：地址运算固定 ADD
            ALUControl_r = 2'b00;     // ADD
            FlagW_r      = 2'b00;
            NoWrite_r    = 1'b0;
        end else if (ALUOp[0]==1'b1 && ALUOp[1]==1'b1) begin
            // 数据处理
            case (funct)
                4'b0100: begin // ADD
                    ALUControl_r = 2'b00;
                    FlagW_r      = Instr[20] ? 2'b11 : 2'b00; // 算术更 NZCV
                    NoWrite_r    = 1'b0;
                end
                4'b0010: begin // SUB
                    ALUControl_r = 2'b01;
                    FlagW_r      = Instr[20] ? 2'b11 : 2'b00;
                    NoWrite_r    = 1'b0;
                end
                4'b0000: begin // AND
                    ALUControl_r = 2'b10;
                    FlagW_r      = Instr[20] ? 2'b10 : 2'b00; // 逻辑更 NZ
                    NoWrite_r    = 1'b0;
                end
                4'b1100: begin // ORR
                    ALUControl_r = 2'b11;
                    FlagW_r      = Instr[20] ? 2'b10 : 2'b00; // 逻辑更 NZ
                    NoWrite_r    = 1'b0;
                end
                4'b1010: begin // CMP -> SUB，不写回
                    ALUControl_r = 2'b01;
                    FlagW_r      = 2'b11; // NZCV
                    NoWrite_r    = 1'b1;
                end
                4'b1011: begin // CMN -> ADD，不写回
                    ALUControl_r = 2'b00;
                    FlagW_r      = 2'b11; // NZCV
                    NoWrite_r    = 1'b1;
                end
                4'b1000,       // TST -> AND，不写回
                4'b1001: begin // TEQ -> AND，不写回
                    ALUControl_r = 2'b10;
                    FlagW_r      = 2'b10; // NZ
                    NoWrite_r    = 1'b1;
                end
                default: begin
                    ALUControl_r = 2'b00;
                    FlagW_r      = 2'b00;
                    NoWrite_r    = 1'b0;
                end
            endcase
        end
    end

    // PC 选择（保持你原逻辑）
    assign PCS = (((Instr[15:12]==4'b1111)  &&  (RegW==1'b1)) || (Branch==1'b1)) ? 1'b1 : 1'b0;

    //-----------------
    assign ALUOp      = ALUOp_r;
    assign Branch     = Branch_r;
    assign MemtoReg   = MemtoReg_r;
    assign MemW       = MemW_r;
    assign ALUSrc     = ALUSrc_r;
    assign ImmSrc     = ImmSrc_r;
    assign RegW       = RegW_r;
    assign RegSrc     = RegSrc_r;
    assign FlagW      = FlagW_r;
    assign ALUControl = ALUControl_r;
    assign NoWrite    = NoWrite_r;
endmodule