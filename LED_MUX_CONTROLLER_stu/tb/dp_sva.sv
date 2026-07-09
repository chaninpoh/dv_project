// ===============================================
// Project      : SDRAM_LED_CONTROLLER
// Description  : UVM CAPSTONE PROJECT
// Author       : Su Lin Poh
// Date         : Fri Sep 26 00:54:27 2025
// ===============================================

`define CHECKER_VALUE_LED_7_SEGMENT(WHC_DIG,NUM_VAL,EXP_VALUE) \
property checker_for_led_digit_``WHC_DIG``_``NUM_VAL;\
      @(posedge clk iff rst_n & init_flag) \
  $changed(dec_digit_``WHC_DIG``) && (dec_digit_``WHC_DIG`` == ``NUM_VAL) ##[80:100] !sel_out[``WHC_DIG``]  |->  seg_out[7:0] ==  ``EXP_VALUE``;\
endproperty \
CHECKER_FOR_DIGIT_``WHC_DIG``_``NUM_VAL: assert property (checker_for_led_digit_``WHC_DIG``_``NUM_VAL)\
  begin\
    $info ("$time checker_for_led_digit``WHC_DIG``_``NUM_VAL PASSES");\
  end\
  else $error("$time checker_for_led_digit``WHC_DIG``_``NUM_VAL: SVA ERROR");\




module dp_sva (
	input clk,rst_n,
	input [5:0] sel_out,
	input [7:0] seg_out,
	input [19:0] error_q

);

logic [3:0] dec_digit_0;
logic [3:0] dec_digit_1;
logic [3:0] dec_digit_2;
logic [3:0] dec_digit_3;
logic [3:0] dec_digit_4;
logic [3:0] dec_digit_5;

logic [31:0] error_dec; 

assign error_dec = error_q;
logic [31:0] cnt=0;
logic init_flag = 0;

//init time
always@(posedge clk) begin
cnt = cnt+1;
if (cnt > 1002)
begin
init_flag <= 1;
end
end

always@(error_q) begin
	dec_digit_0 = error_q%10; 
	dec_digit_1 = (error_q/10)%10;
	dec_digit_2 = (error_q/100)%10; 
	dec_digit_3 = (error_q/1000)%10; 
	dec_digit_4 = (error_q/10000)%10; 
	dec_digit_5 = (error_q/100000)%10; 
end



/*property checker_for_led_digit_0_0;
      @(posedge clk iff rst_n)
  $changed(dec_digit_0) && (dec_digit_0 == 0) ##[80:100] !sel_out[0] |=>  seg_out[7:0] ==  8'h81;
endproperty

CHECKER_FOR_DIGIT_0_0: assert property (checker_for_led_digit_0_0)
  begin
    $info ("$time checker_for_led_digit_0_0 PASSES");
  end
  else $error("$time checker_for_led_digit_0_0: SVA ERROR");*/

//`CHECKER_VALUE_LED_7_SEGMENT(0,0,8'h81)
//`CHECKER_VALUE_LED_7_SEGMENT(1,0,8'h81) //macro -shortcut
//`CHECKER_VALUE_LED_7_SEGMENT(2,0,8'h81)
//`CHECKER_VALUE_LED_7_SEGMENT(3,0,8'h81)
//`CHECKER_VALUE_LED_7_SEGMENT(4,0,8'h81)
//`CHECKER_VALUE_LED_7_SEGMENT(5,0,8'h81)

//__SVA__// 
//ADD Assertions here//
/*
property reset_default_values;
  @(posedge clk )
    $fell(rst_n) |=>  (abc == 'h123);
endproperty

 assert property (reset_default_values)
begin
$info ("$time checker_for_led_digit_reset: SVA PASSES");
end
  else $error("$time checker_for_led_digit_reset: SVA ERROR");*/

//__COV__//
/* covergroup led_mux_cg;

	LED_VALUE_DIG0 : coverpoint dec_digit_0 {
		bins no[] = {[0:9]};
	}

	WHICH_SEL_0 : coverpoint sel_out[0] {
		bins asserted = {0};
	}

       CROSS_CP_0: cross LED_VALUE_DIG0, WHICH_SEL_0; 

endgroup

covergroup led_mux_rst_cg@(rst_n);

        RESET_VALUE : coverpoint rst_n {
                        bins asserted = {0};
                        bins deasserted = {1};
        }

endgroup
*/



//__COV__//led_mux_cg  led_mux_cg_hdl;// Create handle
//__COV__//led_mux_rst_cg led_mux_rst_cg_hdl; 

initial begin
//__COV__//	led_mux_cg_hdl = new();
	//__COV__//led_mux_rst_cg_hdl = new();
end 

//__COV__//always@(posedge clk) begin
	//__COV__//@(sel_out)
	//__COV__//if((sel_out[0] == 0) ||(sel_out[1]  == 0) || (sel_out[2]  == 0) || (sel_out[3]  == 0) || (sel_out[4]  == 0) || (sel_out[5]== 0) )  
	//__COV__//led_mux_cg_hdl.sample();
//__COV__//end


//__COV__//
/*always@(posedge clk) begin 
	@(rst_n)
	led_mux_rst_cg_hdl.sample();
end 
*/

endmodule 
