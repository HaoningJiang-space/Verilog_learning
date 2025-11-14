//-------------------------------------------------------------
// Module: Extend
// Description: Immediate Extension Unit for ARM CPU
//              - Extends immediate values to 32 bits
//              - Supports different immediate formats
//-------------------------------------------------------------
module Extend(
    input [1:0] ImmSrc,
    input [23:0] InstrImm,

    output reg [31:0] ExtImm
);

//-------------------------------------------------------------
// PARAMETER
//-------------------------------------------------------------
    // ImmSrc encoding:
    // 00: Data Processing immediate (8-bit)
    // 01: Load/Store immediate (12-bit)
    // 10: Branch immediate (24-bit, shifted left by 2)

//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Immediate Extension Logic
    //====================================================
    always@(*)begin
        case(ImmSrc)
            2'b00: ExtImm={{24{1'b0}},InstrImm[7:0]};                  // DP I-type: Zero-extend 8-bit
            2'b01: ExtImm={{20{1'b0}},InstrImm[11:0]};                 // LDR/STR-type: Zero-extend 12-bit
            2'b10: ExtImm={{6{InstrImm[23]}},InstrImm[23:0],2'b00};    // Branch-type: Sign-extend 24-bit and shift left by 2
            default: ExtImm=32'b0;
        endcase
    end

endmodule
