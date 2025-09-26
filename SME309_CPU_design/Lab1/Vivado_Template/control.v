`timescale 1ns / 1ps

module key_debounce(
    input  wire       clk,       // System clock
    input  wire       rst_n,     // Active low reset
    input  wire       key_in,    // Raw key input signal
    output wire       key_flag,  // Key event flag (press or release event)
    output reg        key_state  // Current key state (1: released, 0: pressed)
);

    // Internal registers for key event detection
    reg key_press_flag;  // Flag for key press event
    reg key_release_flag;  // Flag for key release event
    
    // Output key event flag (either press or release)
    assign key_flag = key_press_flag | key_release_flag;
    
    // Synchronizers to prevent metastability
    reg [2:0] key_sync;
    always @(posedge clk) begin
        key_sync <= {key_sync[1:0], key_in};
    end
    
    // Edge detection for key transitions
    wire key_posedge;  // Positive edge (key release)
    wire key_negedge;  // Negative edge (key press)
    assign key_posedge = (key_sync[2:1] == 2'b01);  // Transition from 0 to 1
    assign key_negedge = (key_sync[2:1] == 2'b10);  // Transition from 1 to 0
    
    // Debounce counter
    reg [19:0] debounce_cnt;
    
    // State machine for debouncing
    reg [1:0] state;
    localparam IDLE          = 2'd0;  // Waiting for key press
    localparam PRESS_DETECT  = 2'd1;  // Potential key press detected
    localparam PRESSED       = 2'd2;  // Key is confirmed pressed
    localparam RELEASE_DETECT = 2'd3;  // Potential key release detected
    
    // Debounce time constant (adjust based on clock frequency)
    localparam DEBOUNCE_TIME = 20'd1000000 - 1;
    
    // State machine implementation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            key_release_flag <= 1'b0;
            key_press_flag <= 1'b0;
            debounce_cnt <= 0;
            key_state <= 1'b1;  // Default to released state
        end
        else begin
            case (state)
                IDLE: begin
                    // Waiting for key press
                    key_release_flag <= 1'b0;
                    if (key_negedge) begin
                        state <= PRESS_DETECT;  // Potential key press
                    end
                end
                
                PRESS_DETECT: begin
                    // Debouncing potential key press
                    if (key_posedge && (debounce_cnt < DEBOUNCE_TIME)) begin
                        // False trigger - return to IDLE
                        state <= IDLE;
                        debounce_cnt <= 0;
                    end
                    else if (debounce_cnt >= DEBOUNCE_TIME) begin
                        // Debounce time met - confirm key press
                        state <= PRESSED;
                        debounce_cnt <= 0;
                        key_press_flag <= 1'b1;  // Generate key press event
                        key_state <= 1'b0;      // Update key state to pressed
                    end
                    else begin
                        // Keep counting
                        debounce_cnt <= debounce_cnt + 1'b1;
                    end
                end
                
                PRESSED: begin
                    // Key is in pressed state
                    key_press_flag <= 1'b0;  // Clear press flag
                    if (key_posedge) begin
                        state <= RELEASE_DETECT;  // Potential key release
                    end
                end
                
                RELEASE_DETECT: begin
                    // Debouncing potential key release
                    if (key_negedge && (debounce_cnt < DEBOUNCE_TIME)) begin
                        // False trigger - return to PRESSED
                        state <= PRESSED;
                        debounce_cnt <= 0;
                    end
                    else if (debounce_cnt >= DEBOUNCE_TIME) begin
                        // Debounce time met - confirm key release
                        state <= IDLE;
                        debounce_cnt <= 0;
                        key_release_flag <= 1'b1;  // Generate key release event
                        key_state <= 1'b1;        // Update key state to released
                    end
                    else begin
                        // Keep counting
                        debounce_cnt <= debounce_cnt + 1'b1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule

module control(
    input clk,
    input pause,        // high when pressed down
    input speedup,      // high when pressed down
    input speeddown,    // high when pressed down
    output [7:0] addr
);
//-------------------------------------------------------------
// PARAMTER
//-------------------------------------------------------------
    // Speed states
    parameter NORMAL = 2'b00;   // 1 word/second
    parameter HIGH   = 2'b01;   // 4 words/second 
    parameter LOW    = 2'b10;   // 0.25 words/second


//-------------------------------------------------------------
// WIRE&REG
//-------------------------------------------------------------
    reg [1:0] speed_state      ;//cur_state
    reg [1:0] next_speed_state ;//nxt_state
  // Clock dividers for different speeds
    reg  [63:0] counter        ;
  // Button edge detection
    // reg  pause_prev, speedup_prev, speeddown_prev;
    // wire pause_edge, speedup_edge, speeddown_edge;

  // Debounced button signals and flags
    wire pause_flag, speedup_flag, speeddown_flag;
    wire pause_state, speedup_state, speeddown_state;

  // Pause control
    reg       paused     ;
    reg       mem_select ; // 0 for instruction memory, 1 for data memory
    reg [6:0] mem_addr   ; // 7-bit address for each memory (128 words)

    reg [4:0] step       ;


//-------------------------------------------------------------
// BUTTON DEBOUNCING MODULES
//-------------------------------------------------------------
    // Instantiate key debounce modules for all three buttons
    key_debounce pause_debounce(
        .clk(clk),
        .rst_n(1'b1),            // Always enabled
        .key_in(pause),          // Raw button input
        .key_flag(pause_flag),   // Event flag (press or release)
        .key_state(pause_state)  // Current button state
    );
    
    key_debounce speedup_debounce(
        .clk(clk),
        .rst_n(1'b1),             // Always enabled
        .key_in(speedup),         // Raw button input
        .key_flag(speedup_flag),  // Event flag (press or release)
        .key_state(speedup_state) // Current button state
    );
    
    key_debounce speeddown_debounce(
        .clk(clk),
        .rst_n(1'b1),               // Always enabled
        .key_in(speeddown),         // Raw button input
        .key_flag(speeddown_flag),  // Event flag (press or release)
        .key_state(speeddown_state) // Current button state
    );



//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Button Edge Detection 
    //====================================================
        // assign pause_edge = pause & ~pause_prev;
        // assign speedup_edge = speedup & ~speedup_prev;
        // assign speeddown_edge = speeddown & ~speeddown_prev;
    
        // always @(posedge clk) begin
        //     pause_prev <= pause;
        //     speedup_prev <= speedup;
        //     speeddown_prev <= speeddown;
        // end
        wire pause_edge = pause_flag && !pause_state;     // Only detect press events
        wire speedup_edge = speedup_flag && !speedup_state;   // Only detect press events
        wire speeddown_edge = speeddown_flag && !speeddown_state; // Only detect press events


    //====================================================
    // STM: Speed State Machine
    //===================================================
    //---------STM1: state change logic---------
        always@(posedge clk) begin
            speed_state <= next_speed_state;
        end

    //---------STM2: state rule ----------------
        always @(*) begin
            case(speed_state)
                NORMAL: begin
                    if (speedup_edge) begin
                        next_speed_state = HIGH;
                    end else if (speeddown_edge) begin
                        next_speed_state = LOW;
                    end else begin
                        next_speed_state = NORMAL;
                    end
                end
                HIGH: begin
                    if (speedup_edge) begin
                        next_speed_state = HIGH; // stay at HIGH
                    end else if (speeddown_edge) begin
                        next_speed_state = NORMAL;
                    end else begin
                        next_speed_state = HIGH;
                    end
                end
                LOW: begin
                    if (speedup_edge) begin
                        next_speed_state = NORMAL;
                    end else if (speeddown_edge) begin
                        next_speed_state = LOW; // stay at LOW
                    end else begin
                        next_speed_state = LOW;
                    end
                end
                default: begin
                    next_speed_state = NORMAL; // default to NORMAL state
                end
            endcase
        end
    
    //---------STM3: output rule ----------------
        always@(*)begin
            case(speed_state)
                NORMAL : step = 4 ;
                HIGH   : step = 16;
                LOW    : step = 1 ; // Not used in this design
                default: step = 4 ;
            endcase
        end

    
    
    //====================================================
    // Address Generation Logic
    //====================================================
        reg [7:0]  addr_gen=0 ;
        always@(posedge clk)
        begin
            if(counter >= 64'd400000000)begin
                counter <= 0;
                addr_gen <= addr_gen + 1;
            end
            else begin
                counter <= counter + step;
            end
        end
        assign addr =addr_gen;


endmodule
