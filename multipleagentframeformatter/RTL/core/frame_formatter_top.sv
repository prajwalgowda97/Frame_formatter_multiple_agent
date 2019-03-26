//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////Copyright © 2022 PravegaSemi PVT LTD., All rights reserved//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//All works published under Zilla_Gen_0 by PravegaSemi PVT LTD is copyrighted by the Association and ownership  // 
//of all right, title and interest in and to the works remains with PravegaSemi PVT LTD. No works or documents  //
//published under Zilla_Gen_0 by PravegaSemi PVT LTD may be reproduced,transmitted or copied without the express//
//written permission of PravegaSemi PVT LTD will be considered as a violations of Copyright Act and it may lead //
//to legal action.                                                                                         //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////
* File Name : frame_formatter_top.sv

* Purpose :

* Creation Date : 21-02-2023

* Last Modified : Fri 24 Feb 2023 11:18:14 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

module frame_formatter_top #(parameter DATA_WIDTH           = 32,
                             parameter DATA_DEPTH           = 32,
                             parameter ADD_WIDTH_SYNC       = 5,              // Address width of synchronous FIFO
                             parameter ADD_WIDTH_ASYNC      = 6,             // Address width for Asynchronous FIFO
                             parameter ALMOST_FULL_EMPTY    = 2
                             )

                            (   
                              output logic                          out_sop             ,
                              output logic                          out_eop             ,
                              output logic                          sync_fifo_full      ,
                              output logic                          sync_fifo_empty     ,
                              output logic                          sync_almost_full    ,
                              output logic                          sync_almost_empty   ,
                              output logic                          sync_overflow       ,
                              output logic                          sync_underflow      ,
                              output logic [ADD_WIDTH_SYNC:0]       sync_rd_lvl         ,
                              output logic [ADD_WIDTH_SYNC:0]       sync_wr_lvl         ,
                              output logic                          async_fifo_full     ,
                              output logic                          async_almost_full   ,
                              output logic                          async_fifo_empty    ,
                              output logic                          async_almost_empty  ,
                              output logic                          async_overflow      ,
                              output logic                          async_underflow     ,
                              output logic [ADD_WIDTH_ASYNC-1:0]    async_wr_lvl        ,
                              output logic [ADD_WIDTH_ASYNC-1:0]    async_rd_lvl        ,
                              output logic [DATA_WIDTH-1:0]         async_fifo_rd_data  ,

                              input  logic                          Frame_Formatter_TOP_clk                  ,
                              input  logic                          Frame_Formatter_TOP_rstn               ,
                              input  logic                          Frame_Formatter_TOP_sw_rst              ,
                              input  logic                          async_fifo_rd_clk                ,        // read clock for async fifo

                              input  logic                          in_sop              ,
                              input  logic                          in_eop              ,
                              input  logic [DATA_WIDTH-1:0]         sync_fifo_wr_data   ,
                              input  logic                          sync_fifo_wr_en     ,
                              input  logic                          async_fifo_rd_en    ,

                              input  logic [63:0]                   preamble            ,
                              input  logic [47:0]                   dest_addr               ,
                              input  logic [47:0]                   source_addr               ,
                              input  logic [31:0]                   vlan_tag            ,
                              input  logic [15:0]                   eth_type            ,
                              input  logic                          vlan_tag_en         ,
                              input  logic                          in_bypass_en

                            );

        logic [DATA_WIDTH-1:0] data_in_w;            // to connect read data of sync fifo to the data in of frame formatter
        logic sync_fifo_rd_en_w;    // to connect read enable of sync fifo to frame formatter 
        logic async_fifo_wr_en_w;   // to connect write enable of async fifo of frame formatter
        logic [DATA_WIDTH-1:0] data_out_w;           // to connect output data of frame formatter to the input data of async fifo
        logic [6:0] pkt_len_w;      // to connect packet length from sync fifo input to frame formatter output
        logic out_sop_w;
        logic out_eop_w;            //  connect out_sop and out_eop from Frame Formatter module output to input of Async FIFO
        logic in_sop_w;
        logic in_eop_w;
        logic in_bypass_en_latch1_w;
        
        

        

        sync_fifo     #(
                            .ADD_WIDTH              (ADD_WIDTH_SYNC         ),
                            .DATA_WIDTH             (DATA_WIDTH             ),
                            .DATA_DEPTH             (DATA_DEPTH             ),
                            .ALMOST                 (ALMOST_FULL_EMPTY      )
                            
                        )
            sync_fifo1

                        (
                           .rd_data                 (data_in_w              ),
                           .write_full              (sync_fifo_full         ),
                           .read_empty              (sync_fifo_empty        ),
                           .almost_full             (sync_almost_full       ),
                           .almost_empty            (sync_almost_empty      ),
                           .overflow                (sync_overflow          ),
                           .underflow               (sync_underflow         ),
                           .rd_lvl                  (sync_rd_lvl            ),
                           .wr_lvl                  (sync_wr_lvl            ),
                           .wr_data                 (sync_fifo_wr_data      ),
                           .rd_en                   (sync_fifo_rd_en_w      ),
                           .wr_en                   (sync_fifo_wr_en        ),
                           .clk                     (Frame_Formatter_TOP_clk                    ),
                           .rst_n                   (Frame_Formatter_TOP_rstn                  ),
                           .sw_rst                  (Frame_Formatter_TOP_sw_rst),
                           .pkt_len                 (pkt_len_w)              ,
                           .in_sop                  (in_sop)                 ,
                           .in_eop                  (in_eop)                ,
                           .ff_in_sop               (in_sop_w),
                           .ff_in_eop               (in_eop_w)
                        );

        async_fifo       #(
                            .ADDRESS_WIDTH          (ADD_WIDTH_ASYNC        ),
                            .DATA_WIDTH             (DATA_WIDTH             ),
                            .DATA_DEPTH             (DATA_DEPTH             ),
                            .ALMOST                 (ALMOST_FULL_EMPTY      )
                          )
            async_fifo2

                          (
                            .write_full             (async_fifo_full        ),
                            .wr_almost_full         (async_almost_full      ),
                            .read_empty             (async_fifo_empty       ),
                            .rd_almost_empty        (async_almost_empty     ),
                            .overflow               (async_overflow         ),
                            .underflow              (async_underflow        ),
                            .wr_lvl                 (async_wr_lvl           ),
                            .r_lvl                  (async_rd_lvl           ),
                            .rd_data                (async_fifo_rd_data     ),
                            .wclk                   (Frame_Formatter_TOP_clk                    ),
                            .rclk                   (async_fifo_rd_clk                   ),
                            .rst_n                  (Frame_Formatter_TOP_rstn                  ),
                            .sw_rst                 (Frame_Formatter_TOP_sw_rst),
                            .wr_en                  (async_fifo_wr_en_w     ),
                            .rd_en                  (async_fifo_rd_en      ),
                            .wr_data                (data_out_w             ),
                            .i_out_sop              (out_sop_w),
                            .i_out_eop              (out_eop_w),
                            .out_sop                (out_sop),
                            .out_eop                (out_eop),
                            .in_bypass_en_latch1    (in_bypass_en_latch1_w)
                          );

        frame_formatter                          #(
                                                    .DATA_WIDTH         (DATA_WIDTH)                                                  
                                                  )
            ethernet_frame_formatter

                                                  (
                                                    .async_fifo_wr_data     (data_out_w         ),
                                                    .out_sop                (out_sop_w            ),
                                                    .out_eop                (out_eop_w            ),
                                                    .Frame_Formatter_clk    (Frame_Formatter_TOP_clk                ),
                                                    .Frame_Formatter_rstn   (Frame_Formatter_TOP_rstn              ),
                                                    .Frame_Formatter_sw_rst (Frame_Formatter_TOP_sw_rst             ),
                                                    .in_sop                 (in_sop             ),
                                                    .in_eop                 (in_eop             ),
                                                    .sync_fifo_rd_data      (data_in_w          ),
                                                    .preamble               (preamble           ),
                                                    .dest_addr              (dest_addr              ),
                                                    .source_addr            (source_addr              ),
                                                    .vlan_tag               (vlan_tag           ),
                                                    .eth_type               (eth_type           ),
                                                    .vlan_tag_en            (vlan_tag_en        ),
                                                    .in_bypass_en           (in_bypass_en          ),
                                                    .async_fifo_full        (async_fifo_full    ),
                                                    .async_fifo_wr_en_t     (async_fifo_wr_en_w ),
                                                    .sync_fifo_rd_en        (sync_fifo_rd_en_w  ),    // connect with read enable of sync fifo
                                                    .sync_fifo_empty        (sync_fifo_empty    ),
                                                    .pkt_len                (pkt_len_w)         ,
                                                    .ff_in_sop              (in_sop_w),
                                                    .ff_in_eop              (in_eop_w),
                                                    .in_bypass_en_latch1    (in_bypass_en_latch1_w)
                                                    
                                                    
                                                  );

endmodule
