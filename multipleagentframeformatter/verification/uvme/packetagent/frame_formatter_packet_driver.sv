class frame_formatter_packet_driver extends uvm_driver#(frame_formatter_packet_seq_item);
    
     // factory registration 
     `uvm_component_utils(frame_formatter_packet_driver)
     
      // creating interface and sequence item handle
      virtual frame_formatter_packet_interface packet_vif;
      virtual frame_formatter_clk_interface clk_vif;
      frame_formatter_packet_seq_item seq_inst;
     

      // constructor 
      function new(string name= "frame_formatter_packet_driver",uvm_component parent);
          super.new(name,parent);
      endfunction 


     
      // build phase    
      function void build_phase(uvm_phase phase);
          super.build_phase(phase);
     
          if(!uvm_config_db#(virtual frame_formatter_packet_interface)::get(this,"*","packet_vif",packet_vif))
             `uvm_fatal(get_full_name(),"No packet interface found")

         if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
             `uvm_fatal(get_full_name(),"No clk interface found")

      endfunction



      task run_phase(uvm_phase phase);
          super.run_phase(phase);
          `uvm_info(get_type_name(),"Inside packet driver body",UVM_LOW)
       	  @(posedge clk_vif.Frame_Formatter_TOP_clk);
        
          packet_vif.in_sop                      <= 0;
          packet_vif.in_eop                      <= 0; 
          packet_vif.Frame_Formatter_TOP_rstn    <= 0;
         
          forever begin 
              seq_item_port.get_next_item(seq_inst);
              // @(posedge clk_vif.Frame_Formatter_TOP_clk);
              // Assign to interface
             
              `uvm_info(get_type_name(),"Inside packet driver loop",UVM_LOW)
           	      
              packet_vif.in_sop                      <= seq_inst.in_sop;
              packet_vif.in_eop                      <= seq_inst.in_eop; 
              packet_vif.Frame_Formatter_TOP_rstn    <= seq_inst.Frame_Formatter_TOP_rstn;
              packet_vif.sync_fifo_wr_en             <= seq_inst.sync_fifo_wr_en; 
              packet_vif.sync_fifo_wr_data           <= seq_inst.sync_fifo_wr_data;
              packet_vif.Frame_Formatter_TOP_sw_rst  <=  seq_inst.Frame_Formatter_TOP_sw_rst;
         
             `uvm_info(get_type_name(),$sformatf("insop= %b,ineop=%b,frame_rst=%b", packet_vif.in_sop, packet_vif.in_eop,packet_vif.Frame_Formatter_TOP_rstn ),UVM_MEDIUM)
            
             seq_item_port.item_done();
              
           
        end 
             
          
         endtask


endclass


