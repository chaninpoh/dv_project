// APB write sequence — sends one WRITE transaction to the given address
class apb_write_seq extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_write_seq)

  rand bit [31:0] addr;
  rand bit [31:0] data;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr;
    tr = apb_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
      op   == apb_transaction::WRITE;
      addr == local::addr;
      data == local::data;
    })
      `uvm_fatal(get_type_name(), "randomize failed")
    finish_item(tr);
  endtask

endclass
