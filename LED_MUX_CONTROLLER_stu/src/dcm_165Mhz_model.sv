// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================


module dcm_165MHz (

    input  logic clk,        // Input clock
    input  logic RESET,      // Synchronous reset
    output logic CLK_OUT,    // Output clock (derived)
    output logic LOCKED      // Indicates stable output
);



    // Internal registers
    logic [3:0] lock_counter;

    logic clk_div;



    // Simulate clock division (e.g., divide by 2)
    always_ff @(posedge clk) begin

        if (RESET) begin

            clk_div     <= 1'b0;

            lock_counter <= 4'd0;

            LOCKED      <= 1'b0;

        end else begin

            clk_div <= ~clk_div;



            // Simulate lock after a few cycles
            if (lock_counter < 4'd10)

                lock_counter <= lock_counter + 1;

            else

                LOCKED <= 1'b1;

        end

    end



    assign CLK_OUT = clk_div;



endmodule


