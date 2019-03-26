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
* File Name : fifo.sv

* Purpose :

* Creation Date : 26-03-2023

* Last Modified : Fri 24 Feb 2023 11:18:08 PM IST

* Created By :  Pratik Kumar

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/


module async_fifo #(parameter ADDRESS_WIDTH = 6    ,
                    parameter DATA_WIDTH    = 32   ,              
                    parameter DATA_DEPTH    = 32   ,
                    parameter ALMOST        = 3)

                (output logic                           write_full      ,
                 output logic                           wr_almost_full  ,
                 output logic                           read_empty      ,
                 output logic                           rd_almost_empty ,
                 output logic                           overflow        ,
                 output logic                           underflow       ,
                 output logic [ADDRESS_WIDTH - 1 : 0]   wr_lvl          ,
                 output logic [ADDRESS_WIDTH - 1 : 0]   r_lvl           ,
                 output logic [DATA_WIDTH    - 1 : 0]   rd_data         ,
                 input  logic                           wclk            ,
                 input  logic                           rclk            ,
                 input  logic                           rst_n           ,
                 input  logic                           sw_rst          ,
                 input  logic                           wr_en           ,
                 input  logic                           rd_en           ,
                 input  logic [DATA_WIDTH-1:0]          wr_data         ,
                 output logic                           out_sop         ,
                 output logic                           out_eop         ,

                 //////////from frame formatter module //////

                 input logic                            i_out_sop       ,
                 input logic                            i_out_eop       ,
                 input logic                            in_bypass_en_latch1
                 );
    
    logic                       i_out_sop_d1;
    logic                       i_out_eop_d1;
    logic                       i_out_eop_d2;
   
    logic [DATA_WIDTH+1:0]      fifo_mem [DATA_DEPTH-1:0];
    logic [DATA_WIDTH-1:0]      wr_data_d1;
    bit   [ADDRESS_WIDTH-1:0]   wr_ptr;
    bit   [ADDRESS_WIDTH-1:0]   rd_ptr;
    bit   [ADDRESS_WIDTH-1:0]   g_wr_ptr;
    bit   [ADDRESS_WIDTH-1:0]   g_rd_ptr;
    logic                       rd_empty;
    logic                       wr_full;
    logic [ADDRESS_WIDTH-1:0]   w_lvl;
    logic                       wr_en_d1;       // delay write enable by one clk cycle so that write data will be available

    // logic [ADDRESS_WIDTH-1:0] rd_ptr1; 
    logic [ADDRESS_WIDTH-1:0] rd_ptr_sync;
    // logic [ADDRESS_WIDTH-1:0] wr_ptr1;
    logic [ADDRESS_WIDTH-1:0] wr_ptr_sync;
    logic [ADDRESS_WIDTH-1:0] g_rd_ptr1;
    logic [ADDRESS_WIDTH-1:0] g_rd_ptr_sync;
    logic [ADDRESS_WIDTH-1:0] g_wr_ptr1;
    logic [ADDRESS_WIDTH-1:0] g_wr_ptr_sync;
    logic                     rd_valid;
    logic                     wr_valid;
    logic [ADDRESS_WIDTH-1:0] wr_ptr_incr;


assign wr_valid     = wr_en_d1 && !wr_full;
assign read_empty   = rd_empty;
assign write_full   = wr_full;
assign wr_lvl       = w_lvl;
assign wr_ptr_incr  = wr_ptr + {{(ADDRESS_WIDTH-1){1'b0}},1'b1};


//////////// delaying i_out_sop and i_out_eop by one clk cycle ////////////
always_ff@(posedge wclk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                i_out_sop_d1 <= 1'b0;
            end

        else if(sw_rst)
            begin
                i_out_sop_d1 <= 1'b0;
            end

        else
            begin
                i_out_sop_d1 <= i_out_sop;
            end
    end
always_ff@(posedge wclk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                i_out_eop_d1 <= 1'b0;
                i_out_eop_d2 <= 1'b0;
            end

        else if(sw_rst)
            begin
                i_out_eop_d1 <= 1'b0;
                i_out_eop_d2 <= 1'b0;
            end

        else
            begin
                i_out_eop_d1 <= i_out_eop;
                i_out_eop_d2 <= i_out_eop_d1;
            end
    end



///////////////delaying write data by one clock cycle
always_ff@(posedge wclk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                wr_data_d1 <= {DATA_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                wr_data_d1 <= {DATA_WIDTH{1'b0}};
            end

        else
            begin
                wr_data_d1 <= wr_data;
            end
    end


always_ff@(posedge wclk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                wr_en_d1 <= 1'b0;
            end

        else if(sw_rst)
            begin
                wr_en_d1 <= 1'b0;
            end

        else
            begin
                wr_en_d1 <= wr_en;
            end
    end


always_ff @(posedge wclk or negedge rst_n) begin         //// write pointer block
    if(!rst_n)
        begin
            wr_ptr <= {(ADDRESS_WIDTH){1'b0}};
        end

    else if(sw_rst)
        begin
            wr_ptr <= {ADDRESS_WIDTH{1'b0}};
        end
        
    else if(wr_valid) 
        begin
            wr_ptr <= wr_ptr_incr;
        end

    else 
        begin
            wr_ptr <= wr_ptr;
        end
end

assign rd_valid = rd_en && !rd_empty;

always_ff @(posedge rclk or negedge rst_n) begin          //// read pointer block
    if(!rst_n) 
        begin
            rd_ptr <= {(ADDRESS_WIDTH){1'b0}};
        end

    else if(sw_rst)
        begin
            rd_ptr <= {ADDRESS_WIDTH{1'b0}};
        end

    else if(rd_valid) 
        begin
            rd_ptr <= rd_ptr + {{(ADDRESS_WIDTH-1){1'b0}},1'b1};
        end

    else begin
        rd_ptr <= rd_ptr;
        end
end

always_ff @(posedge wclk) begin                         //// To write data in FIFO
        if(wr_valid) begin
            if(in_bypass_en_latch1)
                begin
                    fifo_mem[wr_ptr[ADDRESS_WIDTH-2:0]] <= {i_out_sop,wr_data_d1,i_out_eop};
                end
            else
                begin
                  //  if(!vlan_tag_en_latch)
                    //    begin
                            fifo_mem[wr_ptr[ADDRESS_WIDTH-2:0]] <= {i_out_sop_d1,wr_data_d1,i_out_eop_d2};
                      //  end
                   // else
                     //   begin
                       //     fifo_mem[wr_ptr[ADDRESS_WIDTH-2:0]] <= {i_out_sop_d1,wr_data_d1,i_out_eop_d1};

                       // end

                end
        end
        else begin
            fifo_mem <= fifo_mem;
            end
end

always_ff @(posedge rclk or negedge rst_n) begin                         /// To read data from the FIFO
    if(!rst_n) 
        begin
            rd_data <= {DATA_WIDTH{1'b0}};
        end

    else if(sw_rst)
        begin
            rd_data <= {DATA_WIDTH{1'b0}};
        end
    else if(rd_valid) 
        begin
            rd_data <= fifo_mem[rd_ptr[ADDRESS_WIDTH-2:0]][DATA_WIDTH:1];
            out_sop <= fifo_mem[rd_ptr[ADDRESS_WIDTH-2:0]][DATA_WIDTH+1];
            out_eop <= fifo_mem[rd_ptr[ADDRESS_WIDTH-2:0]][0];
        end

    else if(!rd_valid)
        begin
            rd_data <= {(DATA_WIDTH+1){1'b0}};
            out_eop <= 1'b0;
            out_sop <= 1'b0;
        end

    end
        
       
         
           
            
       

always_ff @(posedge wclk or negedge rst_n) begin               // overflow condition
    if(!rst_n) 
        begin
            overflow <= 1'b0;
        end

    else if(sw_rst)
        begin
            overflow <= 1'b0;
        end

    else if(wr_en_d1 && wr_full) 
        begin
            overflow <= 1'b1;
        end

     else 
         begin
            overflow <= 1'b0;
         end
end

always_ff @(posedge rclk or negedge rst_n) begin           // underflow condition
    if(!rst_n) 
        begin
            underflow <= 1'b0;
        end

    else if(sw_rst)
        begin
            underflow <= 1'b0;
        end

    else if(rd_en && rd_empty) 
        begin
            underflow <= 1'b1;
        end

     else 
         begin
            underflow <= 1'b0;
         end
end

always_ff @(posedge wclk or negedge rst_n) begin       // synchronize gray read pointer in write clock
    if(!rst_n) 
        begin
            {g_rd_ptr1,g_rd_ptr_sync} <= {(2*ADDRESS_WIDTH){1'b0}};
        end

    else if(sw_rst)
        begin
            {g_rd_ptr1,g_rd_ptr_sync} <= {(2*ADDRESS_WIDTH){1'b0}};
        end
    else 
        begin
            {g_rd_ptr1,g_rd_ptr_sync} <= {g_rd_ptr,g_rd_ptr1};
        end
end

always_ff @(posedge rclk or negedge rst_n) begin          // synchronize gray write pointer in read clock
    if(!rst_n) 
        begin
            {g_wr_ptr1,g_wr_ptr_sync} <= {(2*ADDRESS_WIDTH){1'b0}};
        end

    else if(sw_rst)
        begin
            {g_wr_ptr1,g_wr_ptr_sync} <= {(2*ADDRESS_WIDTH){1'b0}};
        end
    else 
        begin
            {g_wr_ptr1,g_wr_ptr_sync} <= {g_wr_ptr,g_wr_ptr1}; 
        end


end

b2g_converter c1(.grey(g_wr_ptr),.binary(wr_ptr));              // convert binary write pointer to gray write pointer
g2b_converter c2(.binary(wr_ptr_sync),.grey(g_wr_ptr_sync));    // convert gray synchronized write pointer to binary synchronized write pointer 
b2g_converter c3(.grey(g_rd_ptr),.binary(rd_ptr));              // convert binary read pointer to gray read pointer
g2b_converter c4(.binary(rd_ptr_sync),.grey(g_rd_ptr_sync));    // convert gray synchronized read pointer to binary synchronized read pointer



assign rd_empty = (rd_ptr == wr_ptr_sync) ? 1'b1 : 1'b0;
assign wr_full = (rd_ptr_sync == {!wr_ptr[ADDRESS_WIDTH-1],wr_ptr[ADDRESS_WIDTH-2:0]}) ? 1'b1 : 1'b0;
assign w_lvl = wr_ptr - rd_ptr_sync;
assign r_lvl = DATA_DEPTH - (wr_ptr_sync-rd_ptr);
assign wr_almost_full = (w_lvl >= DATA_DEPTH - ALMOST)? 1'b1 : 1'b0; 
assign rd_almost_empty = ((wr_ptr_sync-rd_ptr) <= ALMOST) ? 1'b1 : 1'b0;

endmodule



