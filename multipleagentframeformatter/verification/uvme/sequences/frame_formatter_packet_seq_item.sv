class frame_formatter_packet_seq_item extends uvm_sequence_item;
    
    rand logic         Frame_Formatter_TOP_rstn;
    rand logic         Frame_Formatter_TOP_sw_rst;
    rand logic         in_sop;
    rand logic         in_eop;
    
    rand logic             sync_fifo_wr_en;
    rand logic [31:0]      sync_fifo_wr_data;

    function new(string name="frame_formatter_packet_seq_item ");
        super.new(name);
    endfunction


    `uvm_object_utils_begin(frame_formatter_packet_seq_item)
        `uvm_field_int(Frame_Formatter_TOP_rstn,UVM_ALL_ON)
        `uvm_field_int(Frame_Formatter_TOP_sw_rst,UVM_ALL_ON)
	    `uvm_field_int(in_sop,UVM_ALL_ON)
	    `uvm_field_int(in_eop,UVM_ALL_ON)
        `uvm_field_int(sync_fifo_wr_en,UVM_ALL_ON)
	    `uvm_field_int(sync_fifo_wr_data,UVM_ALL_ON)        
    `uvm_object_utils_end

endclass
