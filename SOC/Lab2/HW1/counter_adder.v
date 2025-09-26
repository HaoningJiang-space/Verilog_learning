module full_adder (
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module counter_4bit (
    input wire clk,
    input wire reset,
    output wire [3:0] count
);
    wire [3:0] next_count;
    wire [3:0] carry;
    
    // 实例化4个全加器来计算+1操作
    full_adder fa0 (.a(count[0]), .b(1'b1), .cin(1'b0), .sum(next_count[0]), .cout(carry[0]));
    full_adder fa1 (.a(count[1]), .b(1'b0), .cin(carry[0]), .sum(next_count[1]), .cout(carry[1]));
    full_adder fa2 (.a(count[2]), .b(1'b0), .cin(carry[1]), .sum(next_count[2]), .cout(carry[2]));
    full_adder fa3 (.a(count[3]), .b(1'b0), .cin(carry[2]), .sum(next_count[3]), .cout(carry[3]));
    
    // 4个D触发器实现，用于存储4位整数
    reg [3:0] count_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)
            count_reg <= 4'b0000;
        else
            count_reg <= next_count;
    end
    
    assign count = count_reg;
endmodule