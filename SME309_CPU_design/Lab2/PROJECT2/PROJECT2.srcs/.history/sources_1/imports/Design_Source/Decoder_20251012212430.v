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

    // Main decoder using case on op (use 'x for don't-care)
    always @(*) begin
        // defaults (don't-care)
        PCS_d      = 1'bx;
        RegW_d     = 1'bx;
        MemW_d     = 1'bx;
        MemtoReg_d = 1'bx;
        ALUSrc_d   = 1'bx;
        ImmSrc_d   = 2'bxx;
        RegSrc_d   = 2'bxx;

        casex (op)
            2'b10: begin // Branch
                PCS_d    = 1'b1;      // request PC update (gated by CondLogic)
                ALUSrc_d = 1'b1;      // use immediate offset
                ImmSrc_d = 2'b10;     // branch imm type (sign-extend 24<<2)
                // RegSrc[0] selects R15 for A1; RegSrc[1] don't care
                RegSrc_d = 2'bxx;
                RegSrc_d[0] = 1'b1;
            end
            2'b01: begin // LDR/STR
                MemtoReg_d = L;       // LDR writes from memory
                MemW_d     = ~L;      // STR writes to memory
                RegW_d     = L;       // LDR writes back to Rt (Instr[15:12])
                ALUSrc_d   = 1'b1;    // use 12-bit offset
                ImmSrc_d   = 2'b01;   // load/store immediate type
                // RegSrc[1] selects Rt on B port for STR; RegSrc[0] don't care
                RegSrc_d = 2'bx0;
                if (~L) RegSrc_d[1] = 1'b1; // only meaningful for STR
            end
            2'b00: begin // Data Processing
                RegW_d   = 1'b1;      // DP writes Rd (simplified)
                ALUSrc_d = I;         // immediate or register operand2
                ImmSrc_d = 2'b00;     // DP immediate type (simplified)
                // Other signals remain don't-care ('x)
            end
            default: begin
                // keep 'x defaults
            end
        endcase
    end

    // ALU control with case statements; default don't-care 'x when not applicable
    always @(*) begin
        ALUControl = 2'bxx; // don't care by default
        case (op)
            2'b10: begin // Branch
                ALUControl = 2'b01; // ADD PC + offset
            end
            2'b01: begin // LDR/STR address calc
                ALUControl = 2'b01; // ADD base + offset
            end
            2'b00: begin // DP
                case (funct[3:0])
                    4'b0000: ALUControl = 2'b00; // AND
                    4'b1100: ALUControl = 2'b11; // ORR
                    4'b0100: ALUControl = 2'b01; // ADD
                    4'b0010: ALUControl = 2'b10; // SUB
                    default: ALUControl = 2'b01; // default ADD
                endcase
            end
            default: begin
                // keep 'x
            end
        endcase
    end

    // Flag write enables: only DP & S=1 drives; otherwise don't-care 'x
    always @(*) begin
        FlagW = 2'bxx;
        if (op == 2'b00 && S)
            FlagW = 2'b11;
    end
   
endmodule