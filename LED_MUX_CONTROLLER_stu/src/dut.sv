module dut #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32)(
    input         clk,
    input         rst_n,
     // APB Command Signals

    input  logic [ADDR_WIDTH-1:0]   i_paddr,   // APB Address Bus

    input  logic                    i_pwrite,  // 1=Write, 0=Read

    input  logic                    i_psel,    // Slave Select

    input  logic                    i_penable, // Enable (Access Phase)

    

    // Data Signals

    input  logic [DATA_WIDTH-1:0]   i_pwdata,  // Write Data Bus

    output logic [DATA_WIDTH-1:0]   o_prdata,  // Read Data Bus

    

    // Response Signals

    output logic                    o_pready,  // Slave Ready (Wait States)

    output logic                    o_pslverr,  // Slav

    // Display outputs
    output  [7:0] seg_out,
    output  [5:0] sel_out,


    // Error signal for dp_mux
    input  [19:0]       error_sig


);

parameter ERROR_WIDTH = 20;

wire logic led_enable;
logic error_change_d;
wire logic done;
logic [ERROR_WIDTH-1:0] bus_prev;

dp_mux m3 (
.clk(clk),
.rst_n(rst_n), //fix the bug
.error_q(error_sig & {ERROR_WIDTH{led_enable}}),
.seg_out(seg_out),
.sel_out(sel_out)
);


//logic to detect change: 
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bus_prev <= {ERROR_WIDTH{1'b0}};
            error_change_d <= 1'b0;
        end else begin
            if ( error_sig != bus_prev) begin
                error_change_d <= 1'b1;
            end else begin
                error_change_d <= 1'b0;
            end
            bus_prev <= error_sig;
        end
    end




watchdog_mod#(.TIMEOUT(80)) watchdog_inst(
.clk(clk),
.rst_n(rst_n), 
.kick(error_change_d),
.done_r(done)
);


APB_Slave apb_slave_inst (

        .i_pclk    (clk),

        .i_prstn   (rst_n),

        .i_paddr   (i_paddr),

        .i_pwrite  (i_pwrite),

        .i_psel    (i_psel),

        .i_penable (i_penable),

        .i_pwdata  (i_pwdata),

	.i_done    (done),
	.o_led_enable(led_enable),

        .o_prdata  (o_prdata),

        .o_pready  (o_pready),

        .o_pslverr (o_pslverr)

    );





endmodule
