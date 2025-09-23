// Counter is a simple up counter with enable and reset
module counter #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst_n,   // active-low synchronous reset
    input  wire                 en,      // enable count when high
    input  wire                 dir,     // 1 = up, 0 = down (可选)
    input  wire [WIDTH-1:0]     load,    // parallel load data
    input  wire                 ld,      // load when high (synchronous)
    output reg  [WIDTH-1:0]     q
);

    always @(posedge clk) begin
        if (!rst_n) begin
            q <= {WIDTH{1'b0}};
        end else if (ld) begin
            q <= load;
        end else if (en) begin
            if (dir)
                q <= q + 1'b1;
            else
                q <= q - 1'b1;
        end
    end

endmodule