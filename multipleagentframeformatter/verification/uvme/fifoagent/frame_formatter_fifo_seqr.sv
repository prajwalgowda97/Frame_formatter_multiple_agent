class frame_formatter_fifo_seqr extends uvm_sequencer#(frame_formatter_fifo_seq_item);

    //factory registration
    `uvm_component_utils(frame_formatter_fifo_seqr)

    //constructor
    function new(string name="frame_formatter_fifo_seqr",uvm_component parent);
        super.new(name,parent);
    endfunction
  
endclass
