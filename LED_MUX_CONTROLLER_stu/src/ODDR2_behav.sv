// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


module ODDR2 (
    input  logic C0,     // Rising edge clock
    input  logic C1,     // Falling edge clock
    input  logic CE,     // Clock enable
    input  logic D0,     // Data for rising edge
    input  logic D1,     // Data for falling edge
    input  logic R,      // Synchronous reset
    input  logic S,      // Synchronous set
    output logic Q       // DDR output
);

    logic q_rising, q_falling;

    // Rising edge logic
    always_ff @(posedge C0) begin
        if (R)
            q_rising <= 1'b0;
        else if (S)
            q_rising <= 1'b1;
        else if (CE)
            q_rising <= D0;
    end

     always_ff @(posedge C1) begin
        if (R)
            q_falling <= 1'b0;
        else if (S)
            q_falling <= 1'b1;
        else if (CE)
            q_falling <= D1;
    end

assign Q = C0 ? q_rising : q_falling;


/*

    // Falling edge logic
    always_ff @(posedge C1) begin
        if (R)
            Q <= 1'b0;
        else if (S)
            Q <= 1'b1;
        else if (CE)
            Q <= D1;
    end
*/
endmodule
