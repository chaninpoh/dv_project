//`uvm_analysis_imp_decl(_spi0)

//__TB__//
// Declaration do on the top 
`uvm_analysis_imp_decl(_dp)
`uvm_analysis_imp_decl(_dp_psv)


class env_scoreboard extends uvm_scoreboard; 
  `uvm_component_utils(env_scoreboard)

  //uvm_analysis_imp_spi0#(spi_transaction,env_scoreboard) aep_spi0; //analysis_export
  //uvm_analysis_imp_dp#(type of object monitor will send, component that use
  //write function)
  uvm_analysis_imp_dp#(dp_transaction,env_scoreboard) aep_dp;
  uvm_analysis_imp_dp_psv#(dp_transaction,env_scoreboard) aep_dp_psv;
  
  dp_transaction assoc_array[int]; //create a buffer to keep all expected data.
  int expected_error_cnt_digit_0;
  int expected_error_cnt_digit_1;
  int expected_error_cnt_digit_2;
  int expected_error_cnt_digit_3;
  int expected_error_cnt_digit_4;
  int expected_error_cnt_digit_5;
  int start_compare = 0;
  int pkt_cnt = 0;
  int reset_detected = 0;
  int change_detected = 0; 
  int prev_error_cnt;


function new(string name, uvm_component parent);
   super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  //aep_spi0= new("analysis_port_spi0", this); 
  //__TB__//
  aep_dp = new("analysis_port_dp", this);
  aep_dp_psv = new("analysis_port_dp_psv", this);
endfunction

//__TB__//
 
function void write_dp(dp_transaction TR);
      dp_transaction local_tr;
      $cast(local_tr, TR.clone());
      `uvm_info (get_type_name(), "Display from DP Active Agent", UVM_LOW) //talking to scb
      local_tr.print();
      //for cov
      local_tr.sample();
      //Derive expected results from DP Active Agent
      expected_error_cnt_digit_0 = local_tr.error_cnt%10;
      expected_error_cnt_digit_1 = (local_tr.error_cnt/10)%10;
      //repeat for digit2-6


      // Reset compare state if error change
      if(prev_error_cnt != local_tr.error_cnt) begin
	pkt_cnt = 0;
	start_compare = 0;
      end 
      

      if(pkt_cnt == 80) begin // add a flag to delay when to start compare, because of latency   
         start_compare = 1;	
      end else if(reset_detected) begin
        pkt_cnt = 0;
        start_compare = 0;
        reset_detected = 0;
      end  
	$display("%t cnt %d", $time, pkt_cnt);
	$display("%t reset_detected %d", $time,reset_detected);
      prev_error_cnt = local_tr.error_cnt;
      pkt_cnt++;
	
endfunction       

function void write_dp_psv(dp_transaction TR);
      dp_transaction local_tr;
      $cast(local_tr, TR.clone());
      `uvm_info (get_type_name(), "Display from LED Passive Agent", UVM_LOW) //talking to scb
      local_tr.print();
      //for cov
      local_tr.sample();
      if(start_compare == 1) begin
      `uvm_info (get_type_name(), "Time start", UVM_LOW) //talking to scb
      if(~local_tr.sel_out[0]) begin
	if (local_tr.seg_out == transform(expected_error_cnt_digit_0)) begin
           `uvm_info (get_type_name(), "Digit 0 compare pass", UVM_LOW) //talking to scb
        end else 
            `uvm_error (get_type_name(), $sformatf("Digit 0 compare fails EXP: %x ACT: %x",expected_error_cnt_digit_0, local_tr.seg_out ) ) //talking to scb
      end 
     end 
endfunction

function bit[7:0] transform(int cnt);
	bit[7:0] exp_result; 
     if(cnt == 0) begin
	exp_result = 'h81;
      end 
      //__TB__//
   	return exp_result;
endfunction

function reset_scoreboard();
	reset_detected = 1;
endfunction	
  
  
endclass : env_scoreboard
