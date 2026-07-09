// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Mon Sep 22 11:27:47 2025
// ===============================================

module sdram_model (
    input  logic        s_clk,
    input  logic        s_cke,
    input  logic        s_cs_n,
    input  logic        s_ras_n,
    input  logic        s_cas_n,
    input  logic        s_we_n,
    input  logic [12:0] s_addr,
    input  logic [1:0]  s_ba,
    input  logic        LDQM,
    input  logic        HDQM,
    inout  tri   [15:0] s_dq
);

    // Internal memory array: 4 banks × 8192 rows × 512 columns (16-bit words)
    logic [15:0] mem [0:3][0:8191][0:511];

    logic [2:0] burst_count;

     parameter BURST_LENGTH = 512;




    // Internal state
    typedef enum logic [2:0] {IDLE, ACTIVE, READ, WRITE, PRECHARGE} state_t;
    state_t current_state;

    logic [1:0]  active_bank;
    logic [12:0] active_row;
    logic [10:0]  col_addr;
    logic [10:0]  temp_addr;
    logic [15:0] dq_out;
    logic        dq_drive;
     logic        auto_precharge;



    // SDRAM command decoding
    always_ff @(posedge s_clk) begin
        if (!s_cke || s_cs_n) begin
            current_state <= IDLE;
            dq_drive <= 0;
	    temp_addr <= 0;
        end else begin
            case ({s_ras_n, s_cas_n, s_we_n})
                3'b011: begin // ACTIVE
                    active_bank <= s_ba;
                    active_row  <= s_addr;
                    col_addr <= 0;
                    current_state <= ACTIVE;
                end
                3'b101: begin // READ
                    dq_out <= mem[active_bank][active_row][col_addr];
                    col_addr <= col_addr + 1;
		    dq_drive <= 1;		    
                    current_state <= READ;
                end
                3'b100: begin // WRITE
                    //col_addr <= s_addr[8:0];
                    if (!LDQM) mem[active_bank][active_row][col_addr][7:0]  <= s_dq[7:0];
                    if (!HDQM) mem[active_bank][active_row][col_addr][15:8] <= s_dq[15:8];
                    col_addr <= col_addr + 1;
                    current_state <= WRITE;
                end
                3'b010: begin // PRECHARGE
                    current_state <= PRECHARGE;
                    dq_drive <= 0;
                end
                default: begin
                    current_state <= IDLE;
                    dq_drive <= 0;
                end
            endcase
        end
    end

    // Write operation
    always_ff @(posedge s_clk) begin
        if (current_state == WRITE) begin
        end
    end

    // Drive DQ during READ
    assign s_dq = (dq_drive) ? dq_out : 'z;

endmodule
