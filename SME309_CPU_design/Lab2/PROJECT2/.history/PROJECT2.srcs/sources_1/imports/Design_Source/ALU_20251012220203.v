`timescale 1ns/1ps
module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [1:0] ALUControl,

    output [31:0] ALUResult,
    output [3:0] ALUFlags
    );
     
    // ALUControl encoding (typical for simple ARM lite):
        // ALUControl encoding:
        // 00: AND
        // 01: ADD
        // 10: SUB (implemented as A + (~B) + 1)
        // 11: ORR
        reg [31:0] result_r;
        reg N, Z, C, V;

        // Unified adder path for ADD and SUB (A - B = A + (~B) + 1)
        wire is_add = (ALUControl == 2'b01);
        wire is_sub = (ALUControl == 2'b10);
        wire [31:0] B2  = is_sub ? ~Src_B : Src_B;
        wire        cin = is_sub ? 1'b1   : 1'b0;
        wire [32:0] sum_ext = {1'b0, Src_A} + {1'b0, B2} + cin;

        always @(*) begin
            // default flags
            N = 1'b0; Z = 1'b0; C = 1'b0; V = 1'b0;

            // operation select
            case (ALUControl)
                2'b00: begin // AND
                    result_r = Src_A & Src_B;
                    C = 1'b0; V = 1'b0; // logical ops: define C/V as 0 in this simplified ALU
                end
                2'b01: begin // ADD
                    result_r = sum_ext[31:0];
                    C = sum_ext[32];
                    V = (Src_A[31] == Src_B[31]) && (result_r[31] != Src_A[31]);
                end
                2'b10: begin // SUB (A - B)
                    result_r = sum_ext[31:0];
                    C = sum_ext[32]; // with A + (~B) + 1, carry=1 means no borrow
                    V = (Src_A[31] != Src_B[31]) && (result_r[31] != Src_A[31]);
                end
                default: begin // 2'b11 ORR
                    result_r = Src_A | Src_B;
                    C = 1'b0; V = 1'b0; // logical ops
                end
            endcase

            // common flags
            N = result_r[31];
            Z = (result_r == 32'b0);
        end

        assign ALUResult = result_r;
        assign ALUFlags  = {N, Z, C, V};
endmodule        












