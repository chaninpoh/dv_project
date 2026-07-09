//======================================================
// Watchdog Timer RTL Example
//======================================================
module watchdog_mod #(
    parameter TIMEOUT = 32'd1000000  // timeout cycles
)(
    input  wire clk,        // system clock
    input  wire rst_n,      // active-low reset
    input  wire kick,       // processor "kick" signal
    output reg  done_r     // watchdog reset output
);

    reg [31:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0;
            done_r <= 1'b0;
        end else begin
            if (kick) begin
                // Reset counter when watchdog is kicked
                counter <= 32'd0;
                done_r <= 1'b0;
            end else if (counter < TIMEOUT-1) begin
                // Increment counter until timeout
                counter <= counter + 1;
                done_r <= 1'b0;
            end else begin
                // Timeout reached ? assert reset
                done_r <= 1'b1;
            end
        end
    end

endmodule

