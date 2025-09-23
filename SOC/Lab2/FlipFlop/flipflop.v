// Flip-Flop is a basic memory element in digital electronics.
// It can store one bit of data and is used in various applications such as registers, counters, and memory devices.
// It's truth tableis as follows:
// | D | CLK | Q (next state) |
// |---|-----|----------------|
// | 0 |  0  |       Q        |
// | 0 |  1  |       0        |
// | 1 |  0  |       Q        |
// | 1 |  1  |       1        |
// Where D is the data input, CLK is the clock input, and Q is the output.
module flipflop (
    input wire D,      // Data input
    input wire CLK,    // Clock input
    output reg Q       // Output
);
    always @(posedge CLK) begin
        Q <= D;
    end
endmodule       