class frame_formatter_header_monitor extends uvm_monitor;

    // factory registration 
    `uvm_component_utils(frame_formatter_header_monitor)
 
    // creating handle of interface and sequence item
      

     virtual frame_formatter_header_interface header_vif;
     virtual frame_formatter_clk_interface clk_vif;
     frame_formatter_header_seq_item seq_item_inst;
     uvm_analysis_port #(frame_formatter_header_seq_item) ap;


      //constructor
     function new(string name="frame_formatter_header_monitor",uvm_component parent);
        super.new(name,parent);
        ap = new("ap",this);
     endfunction
    

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //gettinsg virtual interface
        if(!uvm_config_db#(virtual frame_formatter_header_interface)::get(this,"*","header_vif",header_vif))
            `uvm_fatal(get_full_name(),{"unable to get interface in header_monitor","header_vif"})
        if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
            `uvm_fatal(get_full_name(),"No clk interface found")
     
    endfunction



    
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
                    
      `uvm_info(get_type_name(),$sformatf("inside header_monitor"),UVM_MEDIUM)

      // convert pin level to transaction level
      forever begin
        
          @(posedge clk_vif.Frame_Formatter_TOP_clk);
           
       	  seq_item_inst = frame_formatter_header_seq_item::type_id::create("seq_item_inst",this);
       	  seq_item_inst.preamble    = header_vif.preamble;
       	  seq_item_inst.dest_addr   = header_vif.dest_addr;
          seq_item_inst.source_addr    = header_vif.source_addr;
       	  seq_item_inst.Type   = header_vif.Type;
          seq_item_inst.in_bypass_en   = header_vif.in_bypass_en;
	      seq_item_inst.vlan_tag    = header_vif.vlan_tag;
     	  seq_item_inst.vlan_tag_en   = header_vif.vlan_tag_en;
     	 
         `uvm_info(get_type_name(),$sformatf("preamble= %64d,dest_addr=%48d,source_addr=%48d,EthernetType=%16d,inbypass_en=%d,vlan_tag=%32d,vlan_tag_en=%d",seq_item_inst.preamble,seq_item_inst.dest_addr,seq_item_inst.source_addr,seq_item_inst.Type,seq_item_inst.in_bypass_en,seq_item_inst.vlan_tag,seq_item_inst.vlan_tag_en),UVM_MEDIUM)
      
          ap.write(seq_item_inst);
      
         `uvm_info(get_type_name(),$sformatf("after transaction in header_monitor"),UVM_MEDIUM)

    end

  endtask
endclass



 
