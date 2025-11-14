//-------------------------------------------------------------
// Module: ProgramCounter
// Description: Program Counter for ARM CPU
//              - Updates PC on each clock cycle
//              - Supports branch/jump (PCSrc=1) and sequential execution (PCSrc=0)
//-------------------------------------------------------------
module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,

    output reg [31:0] PC,
    output [31:0] PC_Plus_4
);

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // PC Update Logic
    //====================================================
    always@(posedge CLK) begin
        if(Reset) begin
            PC <= 32'd0;                    // Reset PC to 0
        end
        else begin
            if (PCSrc)
                PC <= Result;               // Branch: PC = ALUResult
            else
                PC <= PC_Plus_4;            // Sequential: PC = PC + 4
        end
    end

    //====================================================
    // PC + 4 Calculation
    //====================================================
    assign PC_Plus_4 = PC + 32'd4;          // Next instruction address

endmodule
