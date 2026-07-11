// Physical LED sequence — drives error_q onto the LED interface via led_driver
class led_error_seq extends uvm_sequence #(led_transaction);
  `uvm_object_utils(led_error_seq)

  bit [19:0] error_q;  // set before start()

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    led_transaction tr;
    tr = led_transaction::type_id::create("tr");
    start_item(tr);
    tr.error_q = error_q;
    finish_item(tr);
  endtask

endclass
