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

        // Single adder path used for both ADD and SUB
        wire is_sub = (ALUControl == 2'b10);
        wire [31:0] B2 = is_sub ? ~Src_B : Src_B;
        wire cin       = is_sub ? 1'b1   : 1'b0;
        wire [32:0] sum_ext = {1'b0, Src_A} + {1'b0, B2} + cin;

        always @(*) begin
            // defaults
            N = 1'b0; Z = 1'b0; C = 1'b0; V = 1'b0;
            case (ALUControl)
                2'b00: begin // AND
                    result_r = Src_A & Src_B;
                    C = 1'b0; V = 1'b0;
                end
                2'b01: begin // ADD
                    result_r = sum_ext[31:0];
                    C = sum_ext[32]; // ADD进位
                    // 溢出：A[31]==B[31] 且结果符号变了
                    V = (~(Src_A[31] ^ Src_B[31])) & (result_r[31] ^ Src_A[31]);
                end
                2'b10: begin // SUB
                    result_r = sum_ext[31:0];
                    C = sum_ext[32]; // SUB无借位
                    // 溢出：A[31]!=B[31] 且结果符号与A不同
                    V = (Src_A[31] ^ Src_B[31]) & (result_r[31] ^ Src_A[31]);
                end
                default: begin // ORR
                    result_r = Src_A | Src_B;
                    C = 1'b0; V = 1'b0;
                end
            endcase
            N = result_r[31];
            Z = (result_r == 32'b0);
        end

        assign ALUResult = result_r;
        assign ALUFlags  = {N, Z, C, V};
endmodule












