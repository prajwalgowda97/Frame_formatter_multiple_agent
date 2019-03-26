
// class for fifo coverage
class coverage_model_fifo extends uvm_subscriber #(frame_formatter_fifo_seq_item);

	`uvm_component_utils(coverage_model_fifo)
	
	frame_formatter_fifo_seq_item fifo_seq_item;
	
	covergroup frame_formatter_fifo_covergroup;
		
		option.name= "frame_formatter_fifo_covergroup";
	    option.comment = " To see coverage of Frame_Formatter FIFO AGENT";
	    option.per_instance =1;
	
	    READ: coverpoint  fifo_seq_item.async_fifo_rd_en { bins read_0= {1'b0}; 
							bins read_1 ={1'b1};}


		ASYNC_RD_DATA: coverpoint fifo_seq_item.async_fifo_rd_data{
					 
					 		option.auto_bin_max=32;
					 
					   }
							    
     	SYNC_FIFO_FULL: coverpoint  fifo_seq_item.sync_fifo_full{
					    		bins sync_fifo_full_0 = {1'b0};
					    		bins sync_fifo_full_1 = {1'b1};
					    }

     	SYNC_ALMOST_FULL: coverpoint  fifo_seq_item.sync_almost_full{
					    		bins sync_almost_full_0 = {1'b0};
					    		bins sync_almost_full_1 = {1'b1};
					      }

        SYNC_FIFO_EMPTY: coverpoint  fifo_seq_item.sync_fifo_empty{
					    		bins sync_fifo_empty_0 = {1'b0};
					    		bins sync_fifo_empty_1 = {1'b1}; 
					     }



     	SYNC_ALMOST_EMPTY: coverpoint  fifo_seq_item.sync_almost_empty{
					    		bins sync_almost_empty_0 = {1'b0}; 
					    		bins sync_almost_empty_1 = {1'b1};
						    }

					    
 
   		ASYNC_FIFO_FULL: coverpoint  fifo_seq_item.async_fifo_full{
   	     				      bins async_fifo_full_0 = {1'b0};
   	     				      bins async_fifo_full_1 = {1'b1};
                          }

		ASYNC_FIFO_EMPTY: coverpoint  fifo_seq_item.async_fifo_empty{
					      	   bins async_fifo_empty_0 = {1'b0};
							   bins async_fifo_empty_1 = {1'b1};
					      }



		ASYNC_ALMOST_FULL: coverpoint  fifo_seq_item.async_almost_full{
						    	bins async_almost_full_0 = {1'b0}; 
						        bins async_almost_full_1 = {1'b1};
				           }
		 
		ASYNC_ALMOST_EMPTY: coverpoint  fifo_seq_item.async_almost_empty{
					   		    bins async_almost_empty_0 = {1'b0};
					   		    bins async_almost_empty_1 = {1'b1};
                                             	}




	    OUT_SOP : coverpoint  fifo_seq_item.out_sop{
					  bins out_sop_0 = {1'b0};
				      bins out_sop_1 = {1'b1}; 
				  }

	    OUT_EOP : coverpoint  fifo_seq_item.out_eop{
					   bins out_eop_0 = {1'b0};
					   bins out_eop_1 = {1'b1}; 
						    
			       }

	    SYNC_OVERFLOW : coverpoint  fifo_seq_item.sync_overflow {
					 	    bins sync_overflow_0= {1'b0};
					 	    bins sync_overflow_1= {1'b1};
		   			    }
		     

	   
	    ASYNC_OVERFLOW : coverpoint  fifo_seq_item.async_overflow {
					  	      bins async_overflow_0= {1'b0};
						      bins async_overflow_1= {1'b1}; 
					      }



	     SYNC_UNDERFLOW : coverpoint  fifo_seq_item.sync_underflow {
					  	      bins sync_underflow_0= {1'b0}; 
					   	      bins sync_underflow_1= {1'b1};
					      }

	     ASYNC_UNDERFLOW : coverpoint  fifo_seq_item.sync_underflow {
				 		        bins sync_underflow_0= {1'b0};
				 		        bins sync_underflow_1= {1'b1}; 
				 	       }  

   	    CROSS_OUT_SOP_ASYNC_DATA_OUT: cross OUT_SOP, ASYNC_RD_DATA {
   	                                       bins cross_out_sop_1_async_data_out = binsof(OUT_SOP.out_sop_1) && binsof(ASYNC_RD_DATA);
   	                                       ignore_bins cross_out_sop_0_async_data_out = binsof(OUT_SOP.out_sop_0) && binsof(ASYNC_RD_DATA);
  		                               }	

  	    CROSS_OUT_EOP_ASYNC_DATA_OUT: cross OUT_EOP, ASYNC_RD_DATA{
  	                                       bins cross_out_eop_1_async_data_out = binsof(OUT_EOP.out_eop_1) && binsof(ASYNC_RD_DATA);
  	                                       ignore_bins cross_out_eop_0_async_data_out = binsof(OUT_EOP.out_eop_0) && binsof(ASYNC_RD_DATA);
  	       
	                                   } 				  					    
	endgroup


    function new(string name= "coverage_model_fifo",uvm_component parent);
    	super.new(name,parent);
    	frame_formatter_fifo_covergroup = new();
    endfunction

    
    function void write(input frame_formatter_fifo_seq_item t);
	    fifo_seq_item = new();	 
	 	$cast(fifo_seq_item,t);
	 	frame_formatter_fifo_covergroup.sample();
    endfunction 

endclass         





// class for packet coverage
class coverage_model_packet extends uvm_subscriber #(frame_formatter_packet_seq_item);

	`uvm_component_utils(coverage_model_packet)

	frame_formatter_packet_seq_item packet_seq_item;

 	covergroup frame_formatter_packet_covergroup;
	
     	option.name= "frame_formatter_packet_covergroup";

        ISOP: coverpoint packet_seq_item.in_sop {
					bins in_sop_0 = {1'b0};
					bins in_sop_1 = {1'b1}; 
              }

        IEOP: coverpoint packet_seq_item.in_eop {
					bins in_eop_0 = {1'b0};
					bins in_eop_1 = {1'b1}; 
              }

        SYNC_WR_EN:	coverpoint packet_seq_item.sync_fifo_wr_en{
				        bins sync_fifo_wr_en_0 = {1'b0};
				        bins sync_fifo_wr_en_1 = {1'b1};
				    }


        SYNC_WR_DATA: coverpoint packet_seq_item.sync_fifo_wr_data {
	    
	                      option.auto_bin_max=32; 
	     	     
	                  }

        CROSS_SYNC_WR_EN_SYNC_WRDATA: cross SYNC_WR_EN,SYNC_WR_DATA  iff(packet_seq_item.Frame_Formatter_TOP_rstn){
	                                       ignore_bins cross_pre_bypass_enable_ignore = binsof(SYNC_WR_EN.sync_fifo_wr_en_0) && binsof(SYNC_WR_DATA);	    
	                                  }			    
	    
	   
        CROSS_ISOP_SYNC_WR_EN : cross ISOP,SYNC_WR_EN {

                                     ignore_bins isop0_wr_en0 = binsof(ISOP.in_sop_0) && binsof(SYNC_WR_EN.sync_fifo_wr_en_0);
                                     ignore_bins isop0_wr_en1 = binsof(ISOP.in_sop_0) && binsof(SYNC_WR_EN.sync_fifo_wr_en_1);
                                     ignore_bins isop1_wr_en0 = binsof(ISOP.in_sop_1) && binsof(SYNC_WR_EN.sync_fifo_wr_en_0);
                                }	 

        CROSS_IEOP_SYNC_WR_EN : cross IEOP,SYNC_WR_EN {ignore_bins ieop0_wr_en0 = binsof(IEOP.in_eop_0) && binsof(SYNC_WR_EN.sync_fifo_wr_en_0);
                                     ignore_bins ieop0_wr_en1 = binsof(IEOP.in_eop_0) && binsof(SYNC_WR_EN.sync_fifo_wr_en_1);
                                     ignore_bins ieop1_wr_en0 = binsof(IEOP.in_eop_1) && binsof(SYNC_WR_EN.sync_fifo_wr_en_0);
                                 }		    



    endgroup

    
    function new(string name= "coverage_model_packet",uvm_component parent);
	    super.new(name,parent);
	    frame_formatter_packet_covergroup = new();
    endfunction


    function void write(input frame_formatter_packet_seq_item t);
	    packet_seq_item = new();	 
	    $cast(packet_seq_item,t);
	    frame_formatter_packet_covergroup.sample();
    endfunction
   
endclass
	 
	 

// class for header coverage 
class coverage_model_header extends uvm_subscriber #(frame_formatter_header_seq_item);

    `uvm_component_utils(coverage_model_header)

    coverage_model_packet pkt_class;

    frame_formatter_header_seq_item header_seq_item;

    covergroup frame_formatter_header_covergroup;
	

        option.per_instance =1;
        option.auto_bin_max =16;
        option.name= "frame_formatter_header_covergroup";

        IBYPASS_ENABLE: coverpoint header_seq_item.in_bypass_en  {bins ibypass_en_0 = {1'b0};
						    bins ibypass_en_1= {1'b1};
                         }

        VLAN_TAG_ENABLE : coverpoint header_seq_item.vlan_tag_en  {bins vlan_tag_en_0 = {1'b0};
						      bins vlan_tag_en_1= {1'b1};
                          }

        PREAMBLE:  coverpoint header_seq_item.preamble {

		                option.auto_bin_max=64;
	               }

        DEST_ADDR : coverpoint header_seq_item.dest_addr{
	      
	                    option.auto_bin_max=48;	     
	      
	                }							      


        SOURCE_ADDR : coverpoint header_seq_item.source_addr {
	    
	                       option.auto_bin_max=48;
			    
	                   }

        ETYPE : coverpoint header_seq_item.Type {
	    
	                option.auto_bin_max=16;
	            }

        VLAN_TAG: coverpoint header_seq_item.vlan_tag{
			     
	                  option.auto_bin_max=32;	     
	              }

						     
        CROSS_IBYPASS_VLAN_TAG_EN:  cross IBYPASS_ENABLE,VLAN_TAG_ENABLE;

        CROSS_IBYPASS_HEADER: cross IBYPASS_ENABLE,PREAMBLE,DEST_ADDR,ETYPE,SOURCE_ADDR,VLAN_TAG{ ignore_bins bypass_enable_header = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(PREAMBLE) && binsof(DEST_ADDR)&& binsof(SOURCE_ADDR) && binsof(ETYPE) && binsof(VLAN_TAG);
	    
	                          }


        CROSS_IBYPASS_PREAMBLE: cross IBYPASS_ENABLE, PREAMBLE {ignore_bins cross_pre_bypass_enable_ignore = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(PREAMBLE);}


        CROSS_IBYPASS_DEST_ADDR: cross IBYPASS_ENABLE,DEST_ADDR{ignore_bins cross_dest_bypass_enable_ignore = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(DEST_ADDR);}


  
        CROSS_IBYPASS_SOURCE_ADDR: cross IBYPASS_ENABLE,SOURCE_ADDR{ ignore_bins cross_source_bypass_enable_ignore = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(SOURCE_ADDR);}


        CROSS_IBYPASS_ETYPE: cross IBYPASS_ENABLE,ETYPE {ignore_bins cross_etype_bypass_enable_ignore = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(ETYPE);}

        CROSS_IBYPASS_VLAN_TAG: cross IBYPASS_ENABLE,VLAN_TAG {ignore_bins cross_vlan_bypass_enable_ignore = binsof(IBYPASS_ENABLE.ibypass_en_1) && binsof(VLAN_TAG);}


    endgroup
 


     
    function new(string name= "coverage_model_header",uvm_component parent);
	    super.new(name,parent);
	    frame_formatter_header_covergroup = new();
	endfunction

					
						
    function void write(input frame_formatter_header_seq_item t);
	    header_seq_item = new();	 
	    $cast(header_seq_item,t);	
	    frame_formatter_header_covergroup.sample();
    endfunction 

endclass
    




	   
