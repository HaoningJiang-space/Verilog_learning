module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input MemW,
    input [1:0] FlagW,
    input [3:0] Cond,
    input [3:0] ALUFlags,
    
    output PCSrc,
    output RegWrite,
    output MemWrite
    ); 
    
    wire [1:0] FlagWrite;

    reg CondEx ; 
    reg N = 0, Z = 0, C = 0, V = 0 ;
//-----------------
//Flag Logic
//-----------------
assign FlagWrite[0] = FlagW[0] & CondEx; // Only write flags if condition is met
assign FlagWrite[1] = FlagW[1] & CondEx;


always@(posedge CLK)begin
    if(FlagWrite[1])begin
        N <= ALUFlags[3];
        Z <= ALUFlags[2];
    end

    if(FlagWrite[0]) begin
        C <= ALUFlags[1];
        V <= ALUFlags[0];
    end

end

always@(*)begin
    case(Cond)
        4'b0000: CondEx = Z; // EQ
        4'b0001: CondEx = ~Z; // NE
        4'b0010: CondEx = C; // CS/HS
        4'b0011: CondEx = ~C; // CC/LO
        4'b0100: CondEx = N; // MI
        4'b0101: CondEx = ~N; // PL
        4'b0110: CondEx = V; // VS
        4'b0111: CondEx = ~V; // VC
        4'b1000: CondEx = C & ~Z; // HI
        4'b1001: CondEx = ~C | Z; // LS
        4'b1010: CondEx = (N == V); // GE
        4'b1011: CondEx = (N != V); // LT
        4'b1100: CondEx = (~Z) & (N == V); // GT
        4'b1101: CondEx = Z | (N != V); // LE
        4'b1110: CondEx = 1'b1; // AL (always)
        default: CondEx = 0;
    endcase
end

//-----------------
//Output 
//-----------------
assign PCSrc = (PCS && CondEx) ? 1'b1 : 1'b0; // If PCS is set and condition is met, update PC
assign RegWrite = (RegW && CondEx) ? 1'b1 : 1'b0; // If RegW is set and condition is met, write to register
assign MemWrite = (MemW && CondEx) ? 1'b1 : 1'b0; // If MemW is set and condition is met, write to memory
//-----------------



endmodule