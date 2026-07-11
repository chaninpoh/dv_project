// APB sequence — polls Done register (0x4004) until Done bit[0]=1
// Times out with UVM_FATAL after POLL_TIMEOUT iterations (SPEC §3.5)
class apb_done_poll_seq extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_done_poll_seq)

  localparam int POLL_TIMEOUT = 5000;

  bit done_val;

  function new(string name = "");
    super.new(name);
  endfunction

  task body();
    apb_read_seq rd;
    int cnt = 0;

    done_val = 0;
    while (!done_val) begin
      rd = apb_read_seq::type_id::create($sformatf("rd_done_%0d", cnt));
      rd.addr = 32'h4004;
      rd.start(m_sequencer);
      done_val = rd.rdata[0];
      cnt++;
      if (cnt >= POLL_TIMEOUT)
        `uvm_fatal("POLL_TIMEOUT",
          $sformatf("Done bit not asserted after %0d APB polls", POLL_TIMEOUT))
    end
    `uvm_info(get_type_name(),
      $sformatf("Done=1 seen after %0d polls", cnt), UVM_LOW)
  endtask

endclass
