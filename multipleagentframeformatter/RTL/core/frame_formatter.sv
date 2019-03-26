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
* File Name : frame_formatter.sv

* Purpose :

* Creation Date : 15-02-2023

* Last Modified : Fri 24 Feb 2023 11:46:41 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/






module frame_formatter #(
                         parameter DATA_WIDTH = 32) (
                                       output logic [DATA_WIDTH-1:0]        async_fifo_wr_data      ,       // output data of frame formatter
                                       output logic                         out_sop                 ,       // output start of packet 
                                       output logic                         out_eop                 ,       // output end of packet 
                                       input  logic                         Frame_Formatter_clk     ,       // clock of frame formatter
                                       input  logic                         Frame_Formatter_rstn    ,       // asynchronous active low reset
                                       input  logic                         Frame_Formatter_sw_rst  ,       // synchronous active high reset
                                       input  logic                         in_sop                  ,       // input start of packet
                                       input  logic                         in_eop                  ,       // input end of packet
                                       input  logic [DATA_WIDTH-1:0]        sync_fifo_rd_data       ,       // input data of frame formatter
                                       input  logic [63:0]                  preamble                ,       // preamble of 8 byte
                                       input  logic [47:0]                  dest_addr               ,       // destination address of 6 byte
                                       input  logic [47:0]                  source_addr             ,       // source address of 6 byte
                                       input  logic [31:0]                  vlan_tag                ,       // vlan tag of 4 byte
                                       input  logic [15:0]                  eth_type                ,       // ethernet type of 2 byte
                                       input  logic                         vlan_tag_en             ,       // enable signal for vlan tag

                                       input  logic                         in_bypass_en            ,
                                       input  logic                         ff_in_sop                ,
                                       input  logic                         ff_in_eop                ,


                                       ///////// from Async FIFO ///////////

                                       input  logic                         async_fifo_full         ,
                                       output logic                         async_fifo_wr_en_t       ,
                                      
                                       

                                       ////////  from sync FIFO /////////////

                                       output logic                         sync_fifo_rd_en         ,
                                       input  logic                         sync_fifo_empty         ,
                                       input  logic [6:0]                   pkt_len                 ,
                                       output logic                         in_bypass_en_latch1            // to async fifo
                                     );
                                                logic [1:0]                     pstate          ;       // present state 
                                                logic [1:0]                     nstate          ;       // next state
                                                logic [6:0]                     counter         ;       // count clock pulses during header addition
                                                logic                           in_eop_d1       ;       // in_eop after one clock cycle delay
                                                logic                           in_eop_d2       ;
                                                logic [DATA_WIDTH-1:0]          data_in_latch1   ;       // latch in data coming from sync fifo to properly handle it with counter 
                                                logic                           in_bypass_en_latch;     // registering the bypass enable when it comes with in_sop
                                                logic                           async_fifo_wr_en_temp1;  // used to delay the async_fifo_wr_en by one clk cycle (used when in_bypass_en ==1)
                                                logic                           async_fifo_wr_en_temp;
                                                logic                           ff_in_eop_d1;           // frame formatter eop delay 1
                                                logic                           ff_in_eop_d2;           // frame formatter eop delay 2
                                                logic                           async_fifo_wr_en_d1;
                                                logic                           async_fifo_wr_en;
                                                logic                           ff_in_sop_d1;
                                                logic                           ff_in_sop_d2;
                                                logic                           ff_in_bypass_en_header;     // to indicate that we need to add header along with the data
                                                
                                          
                                         //     logic                           sync_fifo_empty_d1 ;    // delay sync fifo empty by one clk cycle 


                                                logic [63:0]                    preamble_latch  ;   // registering preamble when in_sop asserted
                                                logic [47:0]                    dest_addr_latch       ;
                                                logic [47:0]                    source_addr_latch     ;
                                                logic [31:0]                    vlan_tag_latch        ;
                                                logic [15:0]                    eth_type_latch        ;

                                                logic [2:0]                     count_header          ; // to count the clk pulse when ff_in_bypass_en_header is high
                                                

                                             //   logic                           flag1                 ;
                                                logic                           wr_en_t               ; // used to store wr_en in comb block of FSM output
                                                logic                           ff_in_bypass_en_header_d1;  // delay header by one clk cycle
                                                logic                           in_sop_d1;
                                                logic                           vlan_tag_en_latch       ;
                                                logic                           vlan_tag_en_latch2;
                                                logic                           vlan_tag_en_latch_d1;

                                                logic                           sync_fifo_rd_en_d1;

                                                logic   [6:0]                   sync_fifo_rd_en_count;  // to count for how many clk cycle read enable is high so that when it will reach the packet length, it will make rd en as 0
                                                logic   [3:0]                   flag;                   // to debug sync_fifo_rd_en
                                               logic                            in_bypass_en_latch_d1;
                                               logic                            async_fifo_wr_en_temp2;
                                               logic                            in_bypass_en_latch2;
                                               logic [3:0]                      f;


                        localparam DETECT_SOP       = 2'b00;
                        localparam HEADER_ADDITION  = 2'b01;
                        localparam DATA_TRANSFER    = 2'b10;

                        assign in_bypass_en_latch2 = in_bypass_en_latch;
                        assign in_bypass_en_latch1 = in_bypass_en_latch2;

                        assign vlan_tag_en_latch2 = vlan_tag_en_latch;


                        ///////////delay vlan_tag_en_latch by 1 clock cycle ////////
                        
always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    vlan_tag_en_latch_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    vlan_tag_en_latch_d1 <= 1'b0;
                  
                end

            else
                begin
                    vlan_tag_en_latch_d1 <= vlan_tag_en_latch;
                end

        end



                        ////////// delay sync_fifo_rd_en by one clk cycle ///////


always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    sync_fifo_rd_en_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    sync_fifo_rd_en_d1 <= 1'b0;
                  
                end

            else
                begin
                    sync_fifo_rd_en_d1 <= sync_fifo_rd_en;
                end

        end


                        ////////////// count sync_fifo_rd_en ///////////

always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    sync_fifo_rd_en_count <= 7'd0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    sync_fifo_rd_en_count <= 7'd0;
                  
                end

            else if((sync_fifo_rd_en_count == 7'd0) && sync_fifo_rd_en)
                begin
                    sync_fifo_rd_en_count <= sync_fifo_rd_en_count + 1'b1;
                end

            else if(sync_fifo_rd_en_count == pkt_len)
                begin
                    sync_fifo_rd_en_count <= 7'd0;
                end

            else if(sync_fifo_rd_en)
                begin
                    sync_fifo_rd_en_count <= sync_fifo_rd_en_count + 1'b1;
                end

        end


/////////// registering vlan_tag_en when in_sop asserted ///////////
always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    vlan_tag_en_latch <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    vlan_tag_en_latch <= 1'b0;
                  
                end

            else if(in_sop)
                begin
                    vlan_tag_en_latch <= vlan_tag_en;
                end
        end



                        ////////// delaying in_sop /////////

  always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    in_sop_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    in_sop_d1 <= 1'b0;
                  
                end

            else 
                begin
                    in_sop_d1 <= in_sop;
                end
        end

                       

                        ///////// delaying header by one clk cycle /////////
                        
  always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    ff_in_bypass_en_header_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    ff_in_bypass_en_header_d1 <= 1'b0;
                  
                end

            else 
                begin
                    ff_in_bypass_en_header_d1 <= ff_in_bypass_en_header;
                end
        end



                        //////// count the clk pulse when header asserted //////

       always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
            begin
                if(!Frame_Formatter_rstn)
                    begin
                        count_header <= 3'd0;
                    end

                else if(Frame_Formatter_sw_rst)
                    begin
                        count_header <= 3'd0;
                    end                                                                              

                else if(ff_in_bypass_en_header)
                    begin
                        count_header <= count_header + 1'b1;
                    end

            end


                        

always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     // registering the in_bypass_en when in_sop asserted
    begin
        if(!Frame_Formatter_rstn)
            begin
                ff_in_bypass_en_header <= 1'b0;
            end

        else if(Frame_Formatter_sw_rst)
            begin
                ff_in_bypass_en_header <= 1'b0;
            end

        else if(count_header == 3'd7)
            begin
                ff_in_bypass_en_header <= 1'b0;
            end

        else if(in_sop_d1)
            begin
                if(!in_bypass_en_latch)
                    begin
                        ff_in_bypass_en_header <= 1'b1;
                    end
                else
                    begin
                        ff_in_bypass_en_header <= 1'b0;
                    end
            end
    end



    assign async_fifo_wr_en_temp2 = async_fifo_wr_en;

                      
  /////// delay async fifo wr en by one clk cycle ////////////
    always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    async_fifo_wr_en_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    async_fifo_wr_en_d1 <= 1'b0;
                  
                end

            else 
                begin
                    async_fifo_wr_en_d1 <= async_fifo_wr_en_temp2;
                end
        end

        /////// delay in_bypass_en_latch by one clk cycle ////////////
    always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     
        begin
            if(!Frame_Formatter_rstn)
                begin
                    in_bypass_en_latch_d1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    in_bypass_en_latch_d1 <= 1'b0;
                  
                end

            else 
                begin
                    in_bypass_en_latch_d1 <= in_bypass_en_latch;
                end
        end



 /// and operation between async fifo wr end with delay and without delay //////////
 // assign async_fifo_wr_en_t = async_fifo_wr_en && async_fifo_wr_en_d1;

always_comb
    begin

        /* if(in_bypass_en && vlan_tag_en)
            begin
                async_fifo_wr_en_t = 1'b0;
            end */
         if(!in_bypass_en_latch_d1 && vlan_tag_en_latch_d1)
            begin
                async_fifo_wr_en_t = async_fifo_wr_en_d1;
            end

        else
            begin
                async_fifo_wr_en_t = async_fifo_wr_en && async_fifo_wr_en_d1;
            end
    end


/*
                    always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
                        begin
                            if(!Frame_Formatter_rstn)
                                begin
                                    flag1 <= 1'b0;
                                end

                            else if(Frame_Formatter_sw_rst)
                                begin
                                    flag1 <= 1'b0; 
                                end

                            else if(in_bypass_en_latch && (counter == pkt_len))
                                begin
                                    flag1 <= 1'b1;
                                end

                            else if(!in_bypass_en_latch && (counter == (pkt_len + 7'd6)))
                                begin
                                    flag1 <= 1'b1;
                                end

                            else 
                                begin
                                    flag1 <= 1'b0;
                                end
                        end
 */                     
                        ///////// registering preamble when in_sop asserted //////////

                        always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
                            begin
                                if(!Frame_Formatter_rstn)
                                    begin
                                        preamble_latch      <= 64'd0;
                                        dest_addr_latch     <= 48'd0;
                                        source_addr_latch   <= 48'd0;
                                        vlan_tag_latch      <= 32'd0;
                                        eth_type_latch      <= 16'd0;
                                    end

                                else if(Frame_Formatter_sw_rst)
                                    begin
                                        preamble_latch      <= 64'd0;
                                        dest_addr_latch     <= 48'd0;
                                        source_addr_latch   <= 48'd0;
                                        vlan_tag_latch      <= 32'd0;
                                        eth_type_latch      <= 16'd0;
                                         
                                    end

                                else if(in_sop)
                                    begin
                                        preamble_latch      <= preamble;
                                        dest_addr_latch     <= dest_addr;
                                        source_addr_latch   <= source_addr;
                                        vlan_tag_latch      <= vlan_tag;
                                        eth_type_latch      <= eth_type;
                                        
                                    end
                            end

/////////////////////// delay sync fifo empty by one clk cycle ////////////////
/*
always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
    begin
        if(!Frame_Formatter_rstn)
            begin
                sync_fifo_empty_d1 <= 1'b0;
            end

        else if(Frame_Formatter_sw_rst)
            begin
                sync_fifo_empty_d1 <= 1'b0;
            end

        else 
            begin
                sync_fifo_empty_d1 <= sync_fifo_empty;
            end
    end
*/
always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)     // registering the in_bypass_en when in_sop asserted
    begin
        if(!Frame_Formatter_rstn)
            begin
                in_bypass_en_latch <= 1'b0;
            end

        else if(Frame_Formatter_sw_rst)
            begin
                in_bypass_en_latch <= 1'b0;
            end

        else if(in_sop)
            begin
                in_bypass_en_latch <= in_bypass_en;
            end
    end



////////////////////////////// registering the sync_fifo_rd_data coming from sync fifo ///////////

always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
    begin
        if(!Frame_Formatter_rstn)
            begin
                data_in_latch1 <= {DATA_WIDTH{1'b0}};
            end

        else if(Frame_Formatter_sw_rst)
            begin
                data_in_latch1 <= {DATA_WIDTH{1'b0}};
            end

        else
            begin
                data_in_latch1 <= sync_fifo_rd_data;
            end
    end

////////////////////////////// delaying ff_in_sop by one and two clock cycle /////////////////// 

      always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    ff_in_sop_d1 <= 1'b0;
                    ff_in_sop_d2 <= 1'b0;
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    ff_in_sop_d1 <= 1'b0;
                    ff_in_sop_d2 <= 1'b0;
                end

            else
                begin
                    ff_in_sop_d1 <= ff_in_sop;
                    ff_in_sop_d2 <= ff_in_sop_d1;
                end
        end

    

////////////////////////////// delaying ff_in_eop by one and two clock cycle /////////////////// 

      always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    ff_in_eop_d1 <= 1'b0;
                    ff_in_eop_d2 <= 1'b0;
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    ff_in_eop_d1 <= 1'b0;
                    ff_in_eop_d2 <= 1'b0;
                end

            else
                begin
                    ff_in_eop_d1 <= ff_in_eop;
                    ff_in_eop_d2 <= ff_in_eop_d1;
                end
        end



////////////////////////////// delaying in_eop by one clock cycle /////////////////// 

      always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    in_eop_d1 <= 1'b0;
                    in_eop_d2 <= 1'b0;
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    in_eop_d1 <= 1'b0;
                    in_eop_d2 <= 1'b0;
                end

            else
                begin
                    in_eop_d1 <= in_eop;
                    in_eop_d2 <= in_eop_d1;
                end
        end

//////////////////////////////// present state logic ////////////////////////////////

      always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    pstate <= DETECT_SOP;
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    pstate <= DETECT_SOP;
                end

            else 
                begin
                    pstate <= nstate;
                end
        end

///////////////////////////// next state logic ///////////////////////////////////

      always_comb
        begin
            case(pstate)
                DETECT_SOP : 
                    begin
                            if(ff_in_sop && in_bypass_en_latch)
                                begin
                                    nstate = DATA_TRANSFER;
                                end

                            else if(ff_in_bypass_en_header_d1)
                                begin
                                    nstate = HEADER_ADDITION;
                                end

                            else 
                                begin
                                    nstate = DETECT_SOP;
                                end
                    end

                HEADER_ADDITION : 
                    begin
                             if(async_fifo_full) 
                                 begin
                                    nstate = HEADER_ADDITION;
                                 end

                             else if( (counter == 7'd5 && !vlan_tag_en_latch) || (counter == 7'd6 && vlan_tag_en_latch) )
                                 begin
                                    nstate = DATA_TRANSFER;
                                 end

                            else 
                                begin
                                    nstate = HEADER_ADDITION;
                                end
                    end

                DATA_TRANSFER :
                    begin
                            if(async_fifo_full)
                                begin
                                    nstate = DATA_TRANSFER;
                                end

                            else if(sync_fifo_rd_en)
                                begin
                                    nstate = DATA_TRANSFER;
                                end

                            else if((!sync_fifo_rd_en && in_bypass_en_latch) || (!sync_fifo_rd_en && !in_bypass_en_latch && !vlan_tag_en_latch))
                                begin
                                    nstate = DETECT_SOP;
                                end

                            else if(!sync_fifo_rd_en_d1 && !in_bypass_en_latch && vlan_tag_en_latch)
                                begin
                                    nstate = DETECT_SOP;
                                end
/*
                            if(!in_bypass_en_latch && flag1)
                                begin
                                    nstate = DETECT_SOP;
                                end
*/
                            else if(ff_in_eop_d1 && ff_in_sop && in_bypass_en)
                                begin
                                    nstate = DATA_TRANSFER;
                                end

                           // else if(ff_in_eop_d1 && ff_in_sop && !in_bypass_en)
                             //   begin
                               //     nstate = HEADER_ADDITION;
                               // end

                         //   else if (~(ff_in_eop_d1 && ff_in_sop))
                           //     begin
                             //       nstate = DETECT_SOP;
                               // end

                            else
                                begin
                                    nstate = DATA_TRANSFER;
                                end
                    end

                default     :
                    begin
                                    nstate = DETECT_SOP;
                    end
            endcase
        end

    ////////////////////// output logic for async_fifo_wr_data /////////////////////////

        always_comb
            begin
                case(pstate)
                    DETECT_SOP : 
                        begin
                            if(in_bypass_en_latch)
                                begin
                                    out_sop = 1'b0;
                                    out_eop = ff_in_eop_d2;
                                end

                            else 
                                begin
                                    out_eop = 1'b0;
                                end
                            async_fifo_wr_data = {DATA_WIDTH{1'b0}};
                        end

                    HEADER_ADDITION :
                                                                                                  
                                begin
                                    

                                    if(counter == 7'd0)
                                        begin
                                            out_sop  = 1'b1;
                                            
                                            async_fifo_wr_data = preamble_latch[31:0];
                                            out_eop  = 1'b0;
                                        end

                                    else if(counter == 7'd1)
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = preamble_latch[63:32];
                                            out_eop  = 1'b0;
                                        end

                                    else if(counter == 7'd2)
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = dest_addr_latch[31:0];
                                            out_eop  = 1'b0;
                                        end

                                    else if(counter == 7'd3)
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = {source_addr_latch[15:0],dest_addr_latch[47:32]};
                                            out_eop  = 1'b0;
                                        end

                                    else if(counter == 7'd4)
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = source_addr_latch[47:16];
                                            out_eop  = 1'b0;
                                        end

                                    else if(counter == 7'd5 && vlan_tag_en_latch)
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = vlan_tag_latch[31:0];
                                            out_eop  = 1'b0;
                                        end

                                    else if((counter == 7'd6 && vlan_tag_en_latch) || (counter == 7'd5 && !vlan_tag_en_latch))
                                        begin
                                            out_sop  = 1'b0;
                                            async_fifo_wr_data = {sync_fifo_rd_data[15:0],eth_type_latch[15:0]};
                                            out_eop  = 1'b0;
                                        end

                                    else
                                        begin
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {DATA_WIDTH{1'b0}};
                                            out_eop = 1'b0;
                                        end

                                end
                            
                        

                    DATA_TRANSFER :
                        begin
                            out_eop = ff_in_eop;
                            if(!in_bypass_en_latch_d1)
                          begin
                            if(!vlan_tag_en_latch2)
                                begin
                                    if(counter == pkt_len + 7'd5)
                                        begin
                                            f = 4'd1;
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {{16{1'b0}},data_in_latch1[31:16]};
                                        end

                                    else
                                        begin
                                            f = 4'd2;
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {sync_fifo_rd_data[15:0],data_in_latch1[31:16]};
                                        end
                                end

                            else
                                begin
                                    if(counter == pkt_len + 7'd6)
                                        begin
                                            f = 4'd3;
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {{16{1'b0}},data_in_latch1[31:16]};
                                        end
                                    else
                                        begin
                                            f = 4'd4;
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {sync_fifo_rd_data[15:0],data_in_latch1[31:16]};
                                        end
                                end
                            end


                          /*  if(!in_bypass_en_latch)
                                begin
                                    if(counter < (pkt_len + 7'd6))
                                        begin
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {sync_fifo_rd_data[15:0],data_in_latch1[31:16]};
                                        end
                                    
                                    
                                    else if(!vlan_tag_en_latch && (counter == (pkt_len + 7'd6)))
                                        begin
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {{16{1'b0}},data_in_latch1[31:16]};
                                            
                                        end

                                    else if(vlan_tag_en_latch && (counter == (pkt_len + 7'd5)))
                                        begin
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {{16{1'b0}},data_in_latch1[31:16]};
                                        end */
                                   /* else
                                        begin
                                            out_sop = 1'b0;
                                            async_fifo_wr_data = {sync_fifo_rd_data[15:0],data_in_latch1[31:16]};
                                           
                                        end */
                               // end
                            
                            else
                                begin
                                    
                                    async_fifo_wr_data = data_in_latch1;
                                    out_eop = ff_in_eop_d2;
                                    out_sop = ff_in_sop_d2; 
                                    f = 4'd5;
                                    end
/*
                                    if(async_fifo_wr_en && counter == 7'd0)
                                        begin
                                            out_sop = 1'b1;
                                            out_eop = 1'b0;
                                        end

                                    else if((counter == (pkt_len-7'd1)) && (counter != 7'd0))
                                        begin
                                            out_sop = 1'b0;
                                            out_eop = 1'b1;
                                        end

                                    else
                                        begin
                                            out_sop = 1'b0;
                                            out_eop = 1'b0;
                                        end
*/
                               // end
                            
                            
                        end

                    default :
                        begin
                            out_sop = 1'bx;
                            async_fifo_wr_data = {DATA_WIDTH{1'bx}};
                            out_eop = 1'bx;
                            f = 4'd6;
                        end
                            
                endcase
            end

   //////////////////// output logic for async_fifo_wr_en ////////////////////////

    always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    async_fifo_wr_en <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    async_fifo_wr_en <= 1'b0;
                  
                end

            else if(async_fifo_full)
                begin
                    async_fifo_wr_en <= 1'b0;
                end

            else if(in_bypass_en_latch)
                begin
                    async_fifo_wr_en <= sync_fifo_rd_en;
                end

            else if(ff_in_bypass_en_header)
                begin
                    async_fifo_wr_en <= 1'b1;
                end

            else 
                begin
                    async_fifo_wr_en <= sync_fifo_rd_en;
                end
/*
            else if(ff_in_bypass_en_header)
                begin
                    if(pstate == HEADER_ADDITION)
                        begin
                            async_fifo_wr_en <= 1'b1;
                        end

                    else if(pstate == DATA_TRANSFER)
                        begin
                            async_fifo_wr_en <= sync_fifo_rd_en;
                        end

                    else
                        begin
                            async_fifo_wr_en <= 1'b0;
                        end

                end
*/                
/*
                begin
                    if(counter == (pkt_len-7'd2))
                        begin
                            async_fifo_wr_en <= 1'b0;
                        end
                    else
                        begin                       
                            async_fifo_wr_en <= sync_fifo_rd_en;
                        end
                end
*/
/*
                begin
                    async_fifo_wr_en <= sync_fifo_rd_en;
                                                                                           
                     if(!in_bypass_en_latch && counter < 7'd7)
                        begin
                            async_fifo_wr_en <= 1'b1;
                        end

                    else
                        begin
                            async_fifo_wr_en <= 1'b0;
                        end
                end
*/
        end



/*  
    always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    async_fifo_wr_en_temp1 <= 1'b0;
                
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    async_fifo_wr_en_temp1 <= 1'b0;
                  
                end

            else
                begin
                    if(in_eop_d2)
                        begin
                            async_fifo_wr_en_temp1 <= 1'b0;
                            
                        end

                    else
                        begin
                            async_fifo_wr_en_temp1 <= wr_en_t;
                            
                        end
                end
        end

        assign wr_en_t = async_fifo_wr_en_temp;

        always_comb
            begin
                if(in_bypass_en_latch)
                    begin
                        async_fifo_wr_en = async_fifo_wr_en_temp1;
                    end

                else
                    begin
                        async_fifo_wr_en = async_fifo_wr_en_temp;
                    end
            end

   always_comb
    begin
        case(pstate)
            DETECT_SOP :

                begin
                    async_fifo_wr_en_temp = 1'b0;
                end

            HEADER_ADDITION :

                begin
                    if(async_fifo_full)
                        begin
                            async_fifo_wr_en_temp = 1'b0;
                        end
                    else 
                        begin
                            async_fifo_wr_en_temp = 1'b1;
                        end
             
                end

            DATA_TRANSFER :

                begin
                    if(async_fifo_full)
                        begin
                            async_fifo_wr_en_temp = 1'b0;
                        end

                    else
                        begin
                            if(in_bypass_en)
                                begin
                                    async_fifo_wr_en_temp = 1'b1;
                                end
                            else if(!in_bypass_en_latch && counter == pkt_len + 7'd7)
                                begin
                                    async_fifo_wr_en_temp = 1'b0;
                                end
                            
                            else
                                begin
                                    async_fifo_wr_en_temp = async_fifo_wr_en_temp;
                                end
                                   
                               
                        end                             
                end


            default :

                begin
                    async_fifo_wr_en_temp = 1'bx;
                end
        endcase
    end

*/
   //////////////////// output logic for sync_fifo_rd_en ////////////////////////

        always_ff@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
        begin
            if(!Frame_Formatter_rstn)
                begin
                    sync_fifo_rd_en <= 1'b0;
                    flag <= 4'd0;
                end

            else if(Frame_Formatter_sw_rst)
                begin
                    sync_fifo_rd_en <= 1'b0;
                    flag <= 4'd1;
                end

            else if(sync_fifo_empty || async_fifo_full)
                begin   
                    sync_fifo_rd_en <= 1'b0;
                    flag <= 4'd2;
                end

            else if(in_bypass_en_latch)
                begin                                                                                                                                      
                    sync_fifo_rd_en <= 1'b1;
                        flag <= 4'd4;
                end

            else if(!ff_in_bypass_en_header && vlan_tag_en_latch)
                begin
                    if(sync_fifo_rd_en_count == pkt_len)
                        begin
                            sync_fifo_rd_en <= 1'b0;
                            flag <= 4'd3;
                        end

                    else
                        begin
                            flag <= 4'd9;
                        end
                end

            
            else if(ff_in_bypass_en_header && vlan_tag_en_latch)
                begin
                    if(count_header < 3'd6)
                        begin
                            sync_fifo_rd_en <= 1'b0;
                            flag <= 4'd5;
                        end                                                                                       

                    else if(count_header >= 3'd6)
                        begin
                            sync_fifo_rd_en <= 1'b1;
                            flag <= 4'd6;
                        end

                    else 
                        begin
                            flag <= 10;
                        end
                end

            else if(ff_in_bypass_en_header && !vlan_tag_en_latch)
                begin
                    if(count_header < 4'd5)
                        begin
                            sync_fifo_rd_en <= 1'b0;
                            flag <= 4'd7;
                        end                                                                                       

                    else if(count_header >= 4'd5)
                        begin
                            sync_fifo_rd_en <= 1'b1;
                            flag = 4'd12;
                        end

                    else
                        begin
                            flag <= 4'd11;
                        end
                end 

            else
                begin
                    flag <= 4'd8;
                end
        end


/*
   always_comb
    begin
        case(pstate)
            DETECT_SOP :

                begin
                    sync_fifo_rd_en = 1'b0;
                end

            HEADER_ADDITION :

                begin

                    if(sync_fifo_empty)
                        begin
                            sync_fifo_rd_en = 1'b0;
                        end

                    else if((counter == 3'd5 || counter == 3'd6) || (counter == 3'd4 && !vlan_tag_en))
                  //  else if(counter ==3'd4)
                        begin
                            sync_fifo_rd_en = 1'b1;
                        end

                    else
                        begin
                            sync_fifo_rd_en = 1'b0;
                        end
                end

            DATA_TRANSFER :

                begin
*/
                /*
                    if(sync_fifo_empty)
                        begin
                            sync_fifo_rd_en = 1'b0;
                        end
                    else
                        */
                      //  begin
                      //      sync_fifo_rd_en = 1'b1;
                      //  end
 /*                   
                end

            default :

                begin
                    sync_fifo_rd_en = 1'bx;
                end
        endcase
    end

*/

   ///////////////////// counter logic ///////////////////////////

        always@(posedge Frame_Formatter_clk or negedge Frame_Formatter_rstn)
            begin
                if(!Frame_Formatter_rstn)
                    begin
                        counter <= 3'd0;
                    end

                else if(Frame_Formatter_sw_rst)
                    begin
                        counter <= 3'd0;
                    end

                else if(pstate == DETECT_SOP)
                    begin
                        counter <= 3'd0;
                    end

                else if(pstate == HEADER_ADDITION)
                    begin
                        if(async_fifo_full)
                            begin
                                counter <= counter;
                            end

                        else 
                            begin
                                counter <= counter + 1'b1;
                            end
                    end

                else if(pstate == DATA_TRANSFER)
                    begin
                        if(ff_in_eop_d2)
                            begin
                                counter <= 7'd0;
                            end
                        else
                            begin
                                counter <= counter + 1'b1;
                            end
                    end
            end



        


endmodule
