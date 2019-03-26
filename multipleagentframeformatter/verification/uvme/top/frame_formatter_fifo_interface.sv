interface frame_formatter_fifo_interface();

        // sync fifo signals
	logic             out_sop;
	logic             out_eop;
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
	logic            async_fifo_empty;
	logic            async_fifo_full;
	logic            async_fifo_rd_en;
	logic            async_almost_full;
	logic            async_almost_empty;
	logic            async_overflow;
	logic            async_underflow;
	logic     [5:0]  async_rd_lvl;
	logic     [5:0]  async_wr_lvl;


endinterface
