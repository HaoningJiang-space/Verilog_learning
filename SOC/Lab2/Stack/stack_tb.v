`timescale 1ns / 1ps

module stack_tb();

    parameter DATA_WIDTH = 8;
    parameter STACK_DEPTH = 4;
    parameter ADDR_WIDTH = 2;

    reg clk;
    reg rst_n;
    reg [DATA_WIDTH-1:0] d;
    reg [1:0] op;
    wire [DATA_WIDTH-1:0] q [0:STACK_DEPTH-1];
    wire [ADDR_WIDTH-1:0] sp;
    wire stack_full;
    wire stack_empty;

    localparam LOAD = 2'b00;
    localparam PUSH = 2'b01;
    localparam POP = 2'b10;
    localparam LOAD_PUSH = 2'b11;

    stack #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .d(d),
        .op(op),
        .q(q),
        .sp(sp),
        .stack_full(stack_full),
        .stack_empty(stack_empty)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("stack_test.vcd");
        $dumpvars(0, stack_tb);

        clk = 0;
        rst_n = 0;
        d = 0;
        op = 0;

        #10;
        rst_n = 1;

        $display("=== Stack Operations Test ===");
        $display("Time\tOp\tData\tq[0]\tq[1]\tq[2]\tq[3]\tSP");

        #10;
        d = 8'hAA;
        op = LOAD;
        #10;
        $display("%0t\tLOAD\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #10;
        d = 8'hBB;
        op = PUSH;
        #10;
        $display("%0t\tPUSH\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #10;
        d = 8'hCC;
        op = PUSH;
        #10;
        $display("%0t\tPUSH\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #10;
        op = POP;
        #10;
        $display("%0t\tPOP\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #10;
        d = 8'hDD;
        op = LOAD_PUSH;
        #10;
        $display("%0t\tL&P\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #10;
        op = POP;
        #10;
        $display("%0t\tPOP\t%h\t%h\t%h\t%h\t%h\t%d", $time, d, q[0], q[1], q[2], q[3], sp);

        #20;
        $display("=== Test Complete ===");
        $finish;
    end

endmodule