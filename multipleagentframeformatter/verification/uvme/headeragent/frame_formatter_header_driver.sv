class frame_formatter_header_driver extends uvm_driver#(frame_formatter_header_seq_item);
    
    // factory registration 
    `uvm_component_utils(frame_formatter_header_driver)
    
     // creating interface and sequence item handle
     virtual frame_formatter_header_interface header_vif;
     virtual frame_formatter_clk_interface clk_vif;
     frame_formatter_header_seq_item seq_inst;
    

     // constructor 
     function new(string name= "frame_formatter_header_driver",uvm_component parent);
         super.new(name,parent);
     endfunction 


    // build phase
        
     function void build_phase(uvm_phase phase);
         super.build_phase(phase);
    
         if(!uvm_config_db#(virtual frame_formatter_header_interface)::get(this,"*","header_vif",header_vif))
             `uvm_fatal(get_full_name(),"No header interface found")

              if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
                 `uvm_fatal(get_full_name(),"No clk interface found")
     endfunction

     task run_phase(uvm_phase phase);
         super.run_phase(phase);
         `uvm_info(get_type_name(),"Inside header driver body",UVM_LOW)
         @(posedge clk_vif.Frame_Formatter_TOP_clk);
  
         header_vif.in_bypass_en                 <= 0;
         header_vif.preamble                     <= 0; 
         header_vif.source_addr                  <= 0;
         header_vif.dest_addr                    <= 0;
         header_vif.Type                         <= 0; 
         header_vif.vlan_tag                     <= 0;
         header_vif.vlan_tag_en                  <= 0;
  
         forever begin 
             seq_item_port.get_next_item(seq_inst);
        
             `uvm_info(get_type_name(),"Inside header driver loop",UVM_LOW)

             // @(posedge clk_vif.Frame_Formatter_TOP_clk);
             // Assign to interface
    
             header_vif.in_bypass_en                 <= seq_inst.in_bypass_en;
             header_vif.preamble                     <= seq_inst.preamble; 
             header_vif.source_addr                  <= seq_inst.source_addr;
             header_vif.dest_addr                    <= seq_inst.dest_addr;
             header_vif.Type                         <= seq_inst.Type; 
             header_vif.vlan_tag                     <= seq_inst.vlan_tag;
             header_vif.vlan_tag_en                  <= seq_inst.vlan_tag_en;

            seq_item_port.item_done();
         
        end 
       
     
    endtask


endclass
