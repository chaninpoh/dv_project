// LED interface — SPEC §4.1
interface led_if (input logic clk, ref logic rst_n);

  logic [19:0] error_q;
  logic [7:0]  seg_out;
  logic [5:0]  sel_out;

  modport driver (
    input  clk, rst_n,
    output error_q,
    input  seg_out, sel_out
  );

  modport monitor (
    input clk, rst_n, error_q, seg_out, sel_out
  );

endinterface
