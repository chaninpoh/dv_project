module dp_mux (
	input clk,rst_n, //BUG
	input [19:0] error_q,
	output reg [5:0] sel_out,
	output reg [7:0] seg_out

); 

wire [5:0] in0,in1,in2,in3,in4,in5;


    LED_mux m3
        (
                .clk(clk),
                .rst(rstn), //BUG-3
                .in0(in0),
                .in1(in1),
                .in2(in2),
                .in3(in3),
                .in4(in4),
                .in5(in5), //format: {dp,char[4:0]} , dp is active high
                .seg_out(seg_out),
                .sel_out(sel_out)
    );


        bin2bcd m4
         (
        .clk(clk),
        .rst_n(rst_n),
        .start(1),
        .bin(error_q),//11 digit max of {11{9}}
        .ready(),
        .done_tick(),
        .dig0(in0),
        .dig1(in1),
        .dig2(in2),
        .dig3(in3),
        .dig4(in4),
        .dig5(in5),
        .dig6(),
        .dig7(),
        .dig8(),
        .dig9(),
        .dig10() //not all output will be used(this module is a general-purpose bin2bcd)
    );


endmodule 



