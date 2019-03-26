class frame_formatter_header_seqr extends uvm_sequencer#(frame_formatter_header_seq_item);

     //factory registration
     `uvm_component_utils(frame_formatter_header_seqr)

     //constructor
     function new(string name="frame_formatter_header_seqr",uvm_component parent);
        super.new(name,parent);
     endfunction
  
endclass
