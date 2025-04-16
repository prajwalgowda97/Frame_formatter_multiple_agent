module frame_formatter_top_tb;
	import uvm_pkg::*;
	import frame_formatter_pkg::*;
	`timescale 1ps/1fs 
	`include "uvm_macros.svh"
	frame_formatter_clk_interface clk_vif();
	frame_formatter_header_interface header_vif();
	frame_formatter_packet_interface packet_vif();
	frame_formatter_fifo_interface fifo_vif();

	initial begin 
		uvm_config_db #(virtual frame_formatter_clk_interface):: set(null,"*","clk_vif",clk_vif);
	end

	initial begin 
		uvm_config_db #(virtual frame_formatter_fifo_interface):: set(null,"*","fifo_vif",fifo_vif);
	end
	initial begin 
 		uvm_config_db #(virtual frame_formatter_header_interface):: set(null,"*","header_vif",header_vif);
	end
	initial begin 
 		uvm_config_db #(virtual frame_formatter_packet_interface):: set(null,"*","packet_vif",packet_vif);
	end

	initial begin 
 		run_test();
	end

	initial begin 
		clk_vif.Frame_Formatter_TOP_clk  = 0;
		clk_vif.async_fifo_rd_clk =0;
	
		end


	initial begin 
		packet_vif.Frame_Formatter_TOP_sw_rst=0;
	repeat(2)
		# 1570;
	packet_vif.Frame_Formatter_TOP_rstn=0;
	repeat(2)
	# 1570;
	packet_vif.Frame_Formatter_TOP_rstn=1;

end
	initial begin 

 		forever begin 
		        // Clock generation
                	#785 clk_vif.Frame_Formatter_TOP_clk = 1;
     			#785 clk_vif.Frame_Formatter_TOP_clk = 0;

 		end
	end        

	initial begin 
		forever begin 
	     		#750 clk_vif.async_fifo_rd_clk = ~clk_vif.async_fifo_rd_clk;
	 	end
	end        

        
        // Dut instantiation
	frame_formatter_top DUT ( .Frame_Formatter_TOP_clk      (clk_vif.Frame_Formatter_TOP_clk),
		       	.Frame_Formatter_TOP_rstn     (packet_vif.Frame_Formatter_TOP_rstn),
		       .Frame_Formatter_TOP_sw_rst   (packet_vif.Frame_Formatter_TOP_sw_rst),
		       .async_fifo_rd_clk            (clk_vif.async_fifo_rd_clk),
		       .in_sop                       (packet_vif.in_sop),
		       .in_eop                       (packet_vif.in_eop),
		       .sync_fifo_wr_data            (packet_vif.sync_fifo_wr_data),
		       .sync_fifo_wr_en              (packet_vif.sync_fifo_wr_en),
		       .async_fifo_rd_en             (fifo_vif.async_fifo_rd_en),
		       .preamble                     (header_vif.preamble),
		       .dest_addr                    (header_vif.dest_addr),
		       .source_addr                  (header_vif.source_addr),
		       .vlan_tag                     (header_vif.vlan_tag),
		       .eth_type                     (header_vif.Type),
		       .vlan_tag_en                  (header_vif.vlan_tag_en),
		       .in_bypass_en                 (header_vif.in_bypass_en),
		       .out_sop                      (fifo_vif.out_sop),
		       .out_eop                      (fifo_vif.out_eop),
		       .sync_fifo_full               (fifo_vif.sync_fifo_full),
		       .sync_fifo_empty              (fifo_vif.sync_fifo_empty),
		       .sync_almost_full             (fifo_vif.sync_almost_full),
		       .sync_almost_empty            (fifo_vif.sync_almost_empty),
		       .sync_overflow                (fifo_vif.sync_overflow),
		       .sync_underflow               (fifo_vif.sync_underflow),
		       .sync_rd_lvl                  (fifo_vif.sync_rd_lvl),
		       .sync_wr_lvl                  (fifo_vif.sync_wr_lvl),
		       .async_fifo_full              (fifo_vif.async_fifo_full),
		       .async_almost_full            (fifo_vif.async_almost_full),
		       .async_fifo_empty             (fifo_vif.async_fifo_empty),
		       .async_almost_empty           (fifo_vif.async_almost_empty),
		       .async_overflow               (fifo_vif.async_overflow),
		       .async_underflow              (fifo_vif.async_underflow),
		       .async_wr_lvl                 (fifo_vif.async_wr_lvl),
		       .async_rd_lvl                 (fifo_vif.async_rd_lvl),
		       .async_fifo_rd_data           (fifo_vif.async_fifo_rd_data)
		    );


	initial begin 
		$shm_open("wave.shm");
		$shm_probe("ACTMF");
	end

endmodule
