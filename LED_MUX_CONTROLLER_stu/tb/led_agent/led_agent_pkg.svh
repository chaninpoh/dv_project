


package led_agent_pkg;
     import uvm_pkg::*;
typedef enum {NULL, READ,WRITE} op_t;
parameter PAGE_SIZE = 512;
parameter RCD_DELAY_TIME_IN_CYCLE = 15;


`include "led_transaction.sv"
`include "led_driver.sv" 
`include "led_monitor.sv"
`include "led_agent.sv"


  
endpackage
