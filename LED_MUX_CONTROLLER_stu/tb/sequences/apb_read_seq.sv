// APB read sequence — sends one READ transaction and captures read data
class apb_read_seq extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_read_seq)

  rand bit [31:0] addr;
       bit [31:0] rdata;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr, rsp;
    tr = apb_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with { op == apb_transaction::READ; addr == local::addr; })
      `uvm_fatal(get_type_name(), "randomize failed")
    finish_item(tr);
    get_response(rsp);
    rdata = rsp.data;
  endtask

endclass
