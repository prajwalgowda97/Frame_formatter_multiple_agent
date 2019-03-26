class frame_formatter_packet_sequence extends uvm_sequence #(frame_formatter_header_seq_item);
  
    
    // factory registration 
    `uvm_object_utils(frame_formatter_packet_sequence)
  
    // creating sequence item handle
    frame_formatter_packet_seq_item seq_item_inst;
   
    // constructor 
    function new(string name = "frame_formatter_packet_sequence");
        super.new(name);
    endfunction 


    // Build Phase
    function void build_phase(uvm_phase);
        seq_item_inst= frame_formatter_packet_seq_item::type_id::create("seq_inst_inst");
    endfunction 


    task body();
        `uvm_info(get_type_name(),"Inside body of packet sequence",UVM_LOW)
        //`uvm_do(seq_item_inst)
        start_item(seq_item_inst);
        finish_item(seq_item_inst);
    endtask
endclass



