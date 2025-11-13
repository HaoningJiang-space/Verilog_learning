`timescale 1ns/1ps
module CondLogic(
    input        CLK,
    input        PCS,
    input        RegW,
    input        MemW,
    input  [1:0] FlagW,     // [1]:NZ, [0]:CV
    input  [3:0] Cond,
    input  [3:0] ALUFlags,  // {N,Z,C,V}
    output       PCSrc,
    output       RegWrite,
    output       MemWrite
);
    reg N=0, Z=0, C=0, V=0;
    wire CondEx;
    wire [3:0] Flags = {N,Z,C,V};

    // 条件判断
    function cond_ok;
        input [3:0] cond;
        input [3:0] f;
        reg n,z,c,v;
        begin
            {n,z,c,v} = f;
            case (cond)
                4'h0: cond_ok = (z==1);                    // EQ
                4'h1: cond_ok = (z==0);                    // NE
                4'h2: cond_ok = (c==1);                    // CS/HS
                4'h3: cond_ok = (c==0);                    // CC/LO
                4'h4: cond_ok = (n==1);                    // MI
                4'h5: cond_ok = (n==0);                    // PL
                4'h6: cond_ok = (v==1);                    // VS
                4'h7: cond_ok = (v==0);                    // VC
                4'h8: cond_ok = (c==1 && z==0);            // HI
                4'h9: cond_ok = (c==0 || z==1);            // LS
                4'hA: cond_ok = (n==v);                    // GE
                4'hB: cond_ok = (n!=v);                    // LT
                4'hC: cond_ok = (z==0 && n==v);            // GT
                4'hD: cond_ok = (z==1 || n!=v);            // LE
                4'hE: cond_ok = 1'b1;                      // AL
                default: cond_ok = 1'b1;
            endcase
        end
    endfunction

    assign CondEx   = cond_ok(Cond, Flags);
    assign PCSrc    = PCS    & CondEx;
    assign RegWrite = RegW   & CondEx;
    assign MemWrite = MemW   & CondEx;

    // 标志寄存器写入：在时钟上沿，按位使能
    always @(posedge CLK) begin
        if (FlagW[1]) {N,Z} <= ALUFlags[3:2];
        if (FlagW[0]) {C,V} <= ALUFlags[1:0];
    end
endmodule