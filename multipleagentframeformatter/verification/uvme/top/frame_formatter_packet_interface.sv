interface frame_formatter_packet_interface();

	logic             Frame_Formatter_TOP_rstn;
   	logic             Frame_Formatter_TOP_sw_rst;
   	logic             in_sop;
   	logic             in_eop;
   	logic             sync_fifo_wr_en;
   	logic [31:0]      sync_fifo_wr_data;

 endinterface 
