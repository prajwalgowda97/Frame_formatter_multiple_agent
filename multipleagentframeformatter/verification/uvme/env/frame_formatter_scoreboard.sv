
// Analysis ports 
`uvm_analysis_imp_decl (_con1)
`uvm_analysis_imp_decl (_con2)
`uvm_analysis_imp_decl (_con3)


class frame_formatter_scoreboard extends uvm_scoreboard;


    `uvm_component_utils(frame_formatter_scoreboard)


     // packet seq_item 
    frame_formatter_packet_seq_item seq_item_packet_inst;
    frame_formatter_packet_seq_item seq_item_packet_que[$];



      
    frame_formatter_header_seq_item seq_item_header_inst;
    frame_formatter_header_seq_item seq_item_header_que[$];


    frame_formatter_fifo_seq_item seq_item_fifo_inst;
    frame_formatter_fifo_seq_item seq_item_fifo_que[$];

    // fifo analysis port
    uvm_analysis_imp_con1 #(frame_formatter_fifo_seq_item,frame_formatter_scoreboard) fifo_ap;

    // packet analysis port
    uvm_analysis_imp_con2 #(frame_formatter_packet_seq_item,frame_formatter_scoreboard) packet_ap;

    // header analysis port
    uvm_analysis_imp_con3 #(frame_formatter_header_seq_item,frame_formatter_scoreboard) header_ap;


       logic[31:0] packet_data_write[$];

       logic packet_read_en =0;
       logic packet_write_en_bypass=0;
       logic packet_write_en_bypass_disable=0;
       logic packet_write_en_bypass_disable_buffer=0;
       integer i=0;
       integer j=0;
       logic [31:0] expected_data=0;
       logic [15:0] data_upper =0;
       logic  buffer_delay=0;
       logic buffer_empty =0;
     
       logic async_fifo_empty_buffer=1;
       logic bypass_disable =0;

       function new(string name="frame_formatter_scoreboard",uvm_component parent );
           super.new(name,parent);
       endfunction

       function void build_phase(uvm_phase phase);
           super.build_phase(phase);
           fifo_ap = new("fifo_ap",this);
           packet_ap = new("packet_ap",this);
           header_ap = new("header_ap",this);
        endfunction


       function void write_con1( input frame_formatter_fifo_seq_item seq_item_fifo_inst);
            // Pushing in fifo queue 
            seq_item_fifo_que.push_back(seq_item_fifo_inst);	   
          
       endfunction
      
        function void write_con2( input frame_formatter_packet_seq_item seq_item_packet_inst);
            // Pushing into packet queue 
      	    seq_item_packet_que.push_back(seq_item_packet_inst);
	            
        endfunction

        function void write_con3(input  frame_formatter_header_seq_item seq_item_header_inst);
            // Pushing into header queue
	        seq_item_header_que.push_back(seq_item_header_inst);
     
        endfunction
    


        task run_phase(uvm_phase phase);

            forever begin

                fork 
                    begin
                        wait(seq_item_fifo_que.size()>0);
                        seq_item_fifo_inst = seq_item_fifo_que.pop_front();  // Poping fifo queue      
                    end

                    begin
                        wait(seq_item_packet_que.size()>0);
                        seq_item_packet_inst = seq_item_packet_que.pop_front();  // Poping packet queue 
                    end
          
                    begin
                        wait(seq_item_header_que.size()>0);
                        seq_item_header_inst = seq_item_header_que.pop_front();  // Poping header queue 
                    end

                join

            if(~seq_item_packet_inst.Frame_Formatter_TOP_rstn) begin 
                for(integer i=0;i<1029;i++) 
                    packet_data_write[i]=0;
            end

	        else
	            begin
                    // Async fifo checker
                    if(~seq_item_fifo_inst.async_fifo_full) 
                    `uvm_info("async_fifo_checker_off"," Async fifo is not full",UVM_LOW)
		           
	                else if(seq_item_fifo_inst.async_fifo_full)
	                `uvm_warning("async_fifo_checker_on","Async fifo is full")

            
                    // async fifo && async fifo empty checker
	                assert((~(seq_item_fifo_inst.async_fifo_full && seq_item_fifo_inst.async_fifo_empty)) ||(seq_item_fifo_inst.async_fifo_full ===1'bx) || seq_item_fifo_inst.async_fifo_empty ===1'bx)
		            else
			            `uvm_error("Assertion FAIL:async_full_empty", "Both async_fifo_full and empty high at same time" )

                    // sync fifo && sync fifo empty checker
		            assert ((~(seq_item_fifo_inst.sync_fifo_full && seq_item_fifo_inst.sync_fifo_empty))||(seq_item_fifo_inst.sync_fifo_full ===1'bx) || seq_item_fifo_inst.sync_fifo_empty ===1'bx)
		            else
			            `uvm_error("Assertion FAIL:sync_full_empty", "Both sync_fifo_full and empty high at same time")

                    // out sop && out eop checker
		            assert ((~(seq_item_fifo_inst.out_sop && seq_item_fifo_inst.out_eop)) ||(seq_item_fifo_inst.out_sop ===1'bx) || seq_item_fifo_inst.out_eop ===1'bx)
		            else
			            `uvm_error("Assertion FAIL:out_sop and out_eop", "Both outsop and outeop high at same time")

                    // insop and in_eop checker
		            assert(~(seq_item_packet_inst.in_sop==1 && seq_item_packet_inst.in_eop) ||(seq_item_packet_inst.in_sop ===1'bx) || seq_item_packet_inst.in_eop ===1'bx)
		            else
			            `uvm_error("Assertion FAILr:in_sop and in_eop ", "Both outsop and outeop high at same time")

                    fork
                        begin
                            if(seq_item_packet_inst.in_sop && seq_item_header_inst.in_bypass_en )
		                        begin 
			                        packet_write_en_bypass = 1;  // to choose the ibypass case	           
	                            end

                        end


	                    begin

                            if(seq_item_packet_inst.in_sop && ~seq_item_header_inst.in_bypass_en )
		                        begin 
			                        packet_write_en_bypass_disable = 1;
			                        bypass_disable  =1;
		                            #10 packet_write_en_bypass_disable = 0;  // choose ibypass disable and writing header and data.

	                            end

                        end


                        begin
                            if(seq_item_packet_inst.in_eop )
		                        begin
			                        if(bypass_disable) begin
		                                buffer_delay=1;
		                                #10 packet_write_en_bypass_disable_buffer = 1;
			                        end
		     
                                    else if(packet_write_en_bypass)
			                            #10 packet_write_en_bypass =0;  
	                            end

                        end


                        begin
		                    if(  seq_item_packet_inst.sync_fifo_wr_en && packet_write_en_bypass) 
		                        begin
                                    // Bypass enabled storing data
	                                wait(packet_data_write.size()>0)
                                    packet_data_write[i] = seq_item_packet_inst.sync_fifo_wr_data;
		                            `uvm_info(get_type_name(),$sformatf("packet_data_write_infifo_bypass=%32h,iforbypass=%d",packet_data_write[i],i),UVM_MEDIUM)
		                            i=i+1;
	                            end
                        end

                        begin 
	                        if(~seq_item_header_inst.in_bypass_en && bypass_disable ) 
		                        begin
                                    //  Bypass disabled storing header and data
                                    
                                                                                                   
			                        `uvm_info(get_type_name(),$sformatf("i_forbypass_disable=%d",i),UVM_MEDIUM)     
		                            if( seq_item_packet_inst.sync_fifo_wr_en && packet_write_en_bypass_disable) 
			                            begin 
			                                packet_data_write[i] = seq_item_header_inst.preamble[31:0];
			                                `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
			                                i= i+1;
			                                packet_data_write[i] = seq_item_header_inst.preamble[63:32];
			                                `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                            i= i+1;
			                                packet_data_write[i] = seq_item_header_inst.dest_addr[31:0];
			                                `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
			                                i=i+1;
			                                packet_data_write[i]= {seq_item_header_inst.source_addr[15:0],seq_item_header_inst.dest_addr[47:32]};
                                            `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                            i=i+1;
                                            packet_data_write[i]= seq_item_header_inst.source_addr[47:16];
                                            `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                            i= i+1;
                 
                                            if(seq_item_header_inst.vlan_tag_en) 
                                                begin
                                                     packet_data_write[i]= seq_item_header_inst.vlan_tag;
                                                     `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                                     i= i+1;
                                                 end
                                                packet_data_write[i]= {seq_item_packet_inst.sync_fifo_wr_data[15:0],seq_item_header_inst.Type};
                                                `uvm_info(get_type_name(),$sformatf("packet_data_write[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                                i= i+1;
                                                data_upper = seq_item_packet_inst.sync_fifo_wr_data[31:16];
                                            end

                                            else if((seq_item_packet_inst.sync_fifo_wr_en | buffer_delay) && (~packet_write_en_bypass_disable)  ) 
                                                begin
                                                if(~packet_write_en_bypass_disable_buffer) begin
                                                    packet_data_write[i] = {seq_item_packet_inst.sync_fifo_wr_data[15:0],data_upper};
                                                    `uvm_info(get_type_name(),$sformatf("packet_data_write_infifo[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                                    `uvm_info(get_type_name(),"before eop",UVM_MEDIUM)
                                                    data_upper = seq_item_packet_inst.sync_fifo_wr_data[31:16];
                                                    i= i+1;
                                                end

                                                else if(packet_write_en_bypass_disable_buffer) begin
                                                     packet_data_write[i] = {16'h0,data_upper};
                                                     `uvm_info(get_type_name(),"After eop logic",UVM_MEDIUM)
                                                     `uvm_info(get_type_name(),$sformatf("packet_data_write_infifo[%d]=%32h",i,packet_data_write[i]),UVM_MEDIUM)
                                                                                                          
                                                     i= i+1;
                                                     packet_write_en_bypass_disable_buffer =0;
                                                     buffer_delay =0;
                                                     bypass_disable=0;

                                             end

                                        end
                                    end
	                             end
                            join
                         end



                        fork 
                            begin
                                `uvm_info(get_type_name(),$sformatf("out_sop_read=%d",seq_item_fifo_inst.out_sop),UVM_MEDIUM)
                                if(seq_item_fifo_inst.out_sop) 
                                    begin
                                        packet_read_en = 1;
                                    end
                                end

                                begin 
                                    `uvm_info(get_type_name(),$sformatf("out_eop=%d",seq_item_fifo_inst.out_eop),UVM_MEDIUM)
                                    if(seq_item_fifo_inst.out_eop)
                                        begin
                                            #500 packet_read_en = 0;
                                        end
                                end



                                begin 
                    
                                    #1500 async_fifo_empty_buffer = 0 ;
                                    #10 async_fifo_empty_buffer = 1;
                                    `uvm_info(get_type_name(),$sformatf("async_fifo_empty-buffer=%d,async_empty_fifo=%d",async_fifo_empty_buffer,seq_item_fifo_inst.async_fifo_empty),UVM_MEDIUM)
                             
                                end


                                begin
                                   if(buffer_empty)
                                      #1500 buffer_empty =0;
	                            end

	                            begin
	                                         
                                   `uvm_info(get_type_name(),$sformatf("packet_read_en=%d",packet_read_en),UVM_MEDIUM)
                                   `uvm_info(get_type_name(),$sformatf("async_rd_buffer=%d",async_fifo_empty_buffer),UVM_MEDIUM)
                                    if(packet_read_en && seq_item_fifo_inst.async_fifo_rd_en && ~buffer_empty)
	                                    begin
                                            // Taking expected data                            
                                            expected_data = packet_data_write[j];
	                              	        
                                           `uvm_info(get_type_name(),$sformatf("Expected_data= %32h, async_fifo_rd_data=%32h,packet_data_write[%d]%32h",expected_data,seq_item_fifo_inst.async_fifo_rd_data,j,packet_data_write[j]),UVM_MEDIUM)

	                                        j= j+1;
	                                        if(seq_item_fifo_inst.async_fifo_empty)
	                            	        buffer_empty = 1 ;
	                            	        
                                            // Comparision checker
                                            if(expected_data == seq_item_fifo_inst.async_fifo_rd_data)
                                                `uvm_info(get_type_name(),"Pass",UVM_LOW) 
	                                        else 
                                                `uvm_error("FAIL","Data does not Match") 
                                        end
          	   
	                                end
                                join
                            end
                    endtask 
  endclass





