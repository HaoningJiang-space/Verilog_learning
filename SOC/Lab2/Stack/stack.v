module stack #(
    parameter DATA_WIDTH = 8,
    parameter STACK_DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(STACK_DEPTH)
)(
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] d,
    input wire [1:0] op,
    output reg [DATA_WIDTH-1:0] q [0:STACK_DEPTH-1],
    output reg [ADDR_WIDTH-1:0] sp,
    output wire stack_full,
    output wire stack_empty
);

    localparam LOAD = 2'b00;
    localparam PUSH = 2'b01;
    localparam POP = 2'b10;
    localparam LOAD_PUSH = 2'b11;

    assign stack_full = (sp == STACK_DEPTH - 1);
    assign stack_empty = (sp == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp <= 0;
            for (int i = 0; i < STACK_DEPTH; i++) begin
                q[i] <= 0;
            end
        end else begin
            case (op)
                LOAD: begin
                    q[0] <= d;
                    q[1] <= q[0];
                    q[2] <= q[1];
                    q[3] <= q[2];
                    for (int i = 4; i < STACK_DEPTH; i++) begin
                        q[i] <= q[i-1];
                    end
                end

                PUSH: begin
                    if (!stack_full) begin
                        for (int i = STACK_DEPTH-1; i > 0; i--) begin
                            q[i] <= q[i-1];
                        end
                        q[0] <= d;
                        sp <= sp + 1;
                    end
                end

                POP: begin
                    if (!stack_empty) begin
                        for (int i = 0; i < STACK_DEPTH-1; i++) begin
                            q[i] <= q[i+1];
                        end
                        q[STACK_DEPTH-1] <= 0;
                        sp <= sp - 1;
                    end
                end

                LOAD_PUSH: begin
                    if (!stack_full) begin
                        for (int i = STACK_DEPTH-1; i > 0; i--) begin
                            q[i] <= q[i-1];
                        end
                        q[0] <= d;
                        sp <= sp + 1;
                    end
                end

                default: begin
                end
            endcase
        end
    end

endmodule