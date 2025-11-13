module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [1:0] ALUControl,

    output [31:0] ALUResult,
    output [3:0] ALUFlags
    );
     
reg [31:0] Sum;
reg Cout;
reg [31:0] ALUResult_reg;
//----------------------------------------
//ALUControl  ADD:00  SUB:01 AND:10 OR:11
//ALUResult

always@(*)begin
    if(ALUControl==2'b01) // SUB
        {Cout,Sum}=Src_A+~Src_B+1'b1; // A-B = A + ~B + 1  need to be checked
    else if (ALUControl==2'b00) // ADD
        {Cout,Sum}=Src_A+Src_B; // A+B
end



always@(*)begin
    case(ALUControl)
        2'b00: ALUResult_reg=Sum; // ADD
        2'b01: ALUResult_reg=Sum; // SUB
        2'b10: ALUResult_reg=Src_A&Src_B; // AND
        2'b11: ALUResult_reg=Src_A|Src_B; // OR
        default: ALUResult_reg=32'b0;
    endcase
end

assign ALUResult=ALUResult_reg;
//----------------------------------------
//Flags N Z C V

assign ALUFlags[3]=(ALUResult[31]==1'b1)?1'b1:1'b0; // N
assign ALUFlags[2]=(ALUResult==32'd0)?1'b1:1'b0; // Z
assign ALUFlags[1]=Cout && (~ALUControl[1]); // C
assign ALUFlags[0]=( (~ALUControl[1]) && (Src_A[31] ^ Sum[31]) && (~(Src_A[31] ^ Src_B[31] ^ ALUControl[0]))); // V for ADD
                  
//----------------------------------------                                              

endmodule













