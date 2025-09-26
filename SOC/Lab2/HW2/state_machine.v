`timescale 1ns / 1ps

// 6 state machine

// ========================================

module state_machine(
    input clk,
    input reset,
    input nextstate,
    input jumpstate,
    output reg [2:0] state
);

    //-------------------------------------------------------------
    // PARAMTER
    //-------------------------------------------------------------
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;
    parameter S5 = 3'b101;

    //-------------------------------------------------------------
    // WIRE&REG
    //-------------------------------------------------------------
    reg [2:0] next_state;
    
    //-------------------------------------------------------------
    // MAIN LOGIC
    //-------------------------------------------------------------

    //====================================================
    // STM: State Machine
    //====================================================

    //---------STM1: state change logic---------
        always@(posedge clk or posedge reset) begin
            if (reset) begin
                state <= S0;
            end
            else begin
                state <= next_state;
            end
        end
    
    //---------STM2: state rule ---------
    always@(*) begin
        case(state)
            S0: begin
                if (nextstate == 1'b1) 
                    next_state = S1;
                else if (jumpstate == 1'b1)
                    next_state = S2;
                else
                    next_state = S0;
            end
            S1: begin
                if (nextstate == 1'b1) 
                    next_state = S2;
                else if (jumpstate == 1'b1)
                    next_state = S3;
                else
                    next_state = S1;
            end
            S2: begin
                if (nextstate == 1'b1) 
                    next_state = S3;
                else if (jumpstate == 1'b1)
                    next_state = S4;
                else
                    next_state = S2;
            end
            S3: begin
                if (nextstate == 1'b1) 
                    next_state = S4;
                else if (jumpstate == 1'b1)
                    next_state = S5;
                else
                    next_state = S3;
            end
            S4: begin
                if (nextstate == 1'b1) 
                    next_state = S5;
                else if (jumpstate == 1'b1)
                    next_state = S0;
                else
                    next_state = S4;
            end
            S5: begin
                if (nextstate == 1'b1) 
                    next_state = S0;
                else if (jumpstate == 1'b1)
                    next_state = S1;
                else
                    next_state = S5;
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

    //---------STM3: output rule ---------
    always @(posedge clk or posedge reset) begin
        if (reset) 
            state <= S0;
        else 
            state <= next_state;
        end
    end
endmodule