`timescale 1ns / 1ps

module control(
    input clk,
    input pause,        // high when pressed down
    input speedup,      // high when pressed down
    input speeddown,    // high when pressed down
    output [7:0] addr
);

// Speed states
parameter NORMAL = 2'b00;   // 1 word/second
parameter HIGH   = 2'b01;   // 4 words/second
parameter LOW    = 2'b10;   // 0.25 words/second

reg [1:0] speed_state;
reg [1:0] next_speed_state;

// Clock dividers for different speeds
reg [31:0] counter;
reg [31:0] speed_threshold;

// Button edge detection
reg pause_prev, speedup_prev, speeddown_prev;
wire pause_edge, speedup_edge, speeddown_edge;

assign pause_edge = pause & ~pause_prev;
assign speedup_edge = speedup & ~speedup_prev;
assign speeddown_edge = speeddown & ~speeddown_prev;

// Pause control
reg paused;
reg mem_select; // 0 for instruction memory, 1 for data memory
reg [6:0] mem_addr; // 7-bit address for each memory (128 words)

always @(posedge clk) begin
    pause_prev <= pause;
    speedup_prev <= speedup;
    speeddown_prev <= speeddown;
end

// Speed state machine
always @(*) begin
    case (speed_state)
        NORMAL: begin
            if (speedup_edge)
                next_speed_state = HIGH;
            else if (speeddown_edge)
                next_speed_state = LOW;
            else
                next_speed_state = NORMAL;
        end
        HIGH: begin
            if (speedup_edge)
                next_speed_state = NORMAL;
            else if (speeddown_edge)
                next_speed_state = NORMAL;
            else
                next_speed_state = HIGH;
        end
        LOW: begin
            if (speedup_edge)
                next_speed_state = NORMAL;
            else if (speeddown_edge)
                next_speed_state = NORMAL;
            else
                next_speed_state = LOW;
        end
        default: next_speed_state = NORMAL;
    endcase
end

// Set speed threshold based on state
always @(*) begin
    case (speed_state)
        NORMAL: speed_threshold = 1000;           // 仿真用：1000个时钟周期 (~10us)
        HIGH:   speed_threshold = 250;            // 仿真用：250个时钟周期 (~2.5us)
        LOW:    speed_threshold = 4000;           // 仿真用：4000个时钟周期 (~40us)
        default: speed_threshold = 1000;
    endcase
end

// Main control logic
always @(posedge clk) begin
    // Update speed state
    speed_state <= next_speed_state;

    // Handle pause
    if (pause_edge) begin
        paused <= ~paused;
    end

    // Address generation when not paused
    if (!paused) begin
        counter <= counter + 1;

        if (counter >= speed_threshold) begin
            counter <= 0;

            // Increment memory address
            if (mem_addr == 127) begin
                mem_addr <= 0;
                // Switch between instruction and data memory
                if (!mem_select) begin
                    // Finished instruction memory, switch to data memory
                    mem_select <= 1;
                end else begin
                    // Finished data memory, switch back to instruction memory
                    mem_select <= 0;
                end
            end else begin
                mem_addr <= mem_addr + 1;
            end
        end
    end
end

// Combine memory select and address for output
assign addr = {mem_select, mem_addr};

// Initialize
initial begin
    speed_state <= NORMAL;
    counter <= 0;
    paused <= 0;
    mem_select <= 0;
    mem_addr <= 0;
    pause_prev <= 0;
    speedup_prev <= 0;
    speeddown_prev <= 0;
end

endmodule
