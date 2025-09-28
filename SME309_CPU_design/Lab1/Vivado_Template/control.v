//`timescale 1ns / 1ps

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
    reg [1:0] speed_state      =0;//cur_state
    reg [1:0] next_speed_state =0;//nxt_state
  // Clock dividers for different speeds
    reg  [63:0] counter        =0;
  // Button edge detection
    reg  pause_prev, speedup_prev, speeddown_prev;
    wire pause_edge, speedup_edge, speeddown_edge;
  // Pause control
    reg       paused =0    ;
//    reg       mem_select ; // 0 for instruction memory, 1 for data memory
//    reg [6:0] mem_addr   ; // 7-bit address for each memory (128 words)

    reg [4:0] step       ;


//-------------------------------------------------------------
// MAIN LOGIC
//-------------------------------------------------------------

    //====================================================
    // Button Edge Detection 
    //====================================================
        assign pause_edge = pause & ~pause_prev;
        assign speedup_edge = speedup & ~speedup_prev;
        assign speeddown_edge = speeddown & ~speeddown_prev;
    
        always @(posedge clk) begin
            pause_prev <= pause;
            speedup_prev <= speedup;
            speeddown_prev <= speeddown;
        end

    //====================================================
    // Pause Control Logic
    //====================================================
        always @(posedge clk) begin
            if (pause_edge) begin
                paused <= ~paused;  // 切换暂停状态
            end
        end

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
            if (!paused) begin
                if(counter >= 64'd4)begin
                    counter <= 0;
                    addr_gen <= addr_gen + 1;
                end
                else begin
                    counter <= counter + step;
                end
            end
        assign addr =addr_gen;


endmodule