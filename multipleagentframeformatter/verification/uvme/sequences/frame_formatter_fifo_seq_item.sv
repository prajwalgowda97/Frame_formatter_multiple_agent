class frame_formatter_fifo_seq_item extends uvm_sequence_item;

    // sync fifo signals
    logic             sync_fifo_full;
    logic             sync_fifo_empty;
    logic             sync_almost_full;
    logic             sync_almost_empty;
    logic             sync_overflow;
    logic             sync_underflow;
    logic     [5:0]   sync_rd_lvl;
    logic     [5:0]   sync_wr_lvl;

    // async fifo signals
    logic     [31:0] async_fifo_rd_data;
    rand  logic            async_fifo_rd_en;
    logic            async_almost_full;
    logic            async_almost_empty;
    logic            async_overflow;
    logic            async_underflow;
    logic     [5:0]  async_rd_lvl;
    logic     [5:0]  async_wr_lvl;
    logic            async_fifo_full;
    logic            async_fifo_empty;
    logic         out_sop;
    logic         out_eop;



    function new(string name="frame_formatter_fifo_seq_item ");
        super.new(name);
    endfunction
  

    `uvm_object_utils_begin(frame_formatter_fifo_seq_item)
         
	    `uvm_field_int(async_fifo_rd_en,UVM_ALL_ON)
	    `uvm_field_int(sync_fifo_full,UVM_ALL_ON)
	    `uvm_field_int(async_fifo_rd_data,UVM_ALL_ON)
        `uvm_field_int(async_fifo_full,UVM_ALL_ON)
        `uvm_field_int(async_fifo_empty,UVM_ALL_ON)
        `uvm_field_int(sync_fifo_empty,UVM_ALL_ON)
        `uvm_field_int(sync_almost_full,UVM_ALL_ON)
        `uvm_field_int(sync_almost_empty,UVM_ALL_ON)
        `uvm_field_int(sync_overflow,UVM_ALL_ON)
        `uvm_field_int(sync_underflow,UVM_ALL_ON)
        `uvm_field_int(sync_rd_lvl,UVM_ALL_ON)
        `uvm_field_int(sync_wr_lvl,UVM_ALL_ON)
        `uvm_field_int(async_almost_full,UVM_ALL_ON)
        `uvm_field_int(async_almost_empty,UVM_ALL_ON)
        `uvm_field_int(async_overflow,UVM_ALL_ON)
        `uvm_field_int(async_underflow,UVM_ALL_ON)
        `uvm_field_int(async_rd_lvl,UVM_ALL_ON)
        `uvm_field_int(async_wr_lvl,UVM_ALL_ON)
        `uvm_field_int(out_sop,UVM_ALL_ON)
	    `uvm_field_int(out_eop,UVM_ALL_ON)
    `uvm_object_utils_end


endclass
