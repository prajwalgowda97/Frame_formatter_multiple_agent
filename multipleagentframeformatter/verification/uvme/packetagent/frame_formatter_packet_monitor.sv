class frame_formatter_packet_monitor extends uvm_monitor;

    // factory registration 
    `uvm_component_utils(frame_formatter_packet_monitor)
 
    // creating handle of interface and sequence item
    virtual frame_formatter_packet_interface packet_vif;
    virtual frame_formatter_clk_interface clk_vif;
    frame_formatter_packet_seq_item seq_item_inst;
    uvm_analysis_port #(frame_formatter_packet_seq_item) ap;


    //constructor
    function new(string name="frame_formatter_packet_monitor",uvm_component parent);
        super.new(name,parent);
        ap = new("ap",this);
    endfunction
    

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //gettinsg virtual interface
        if(!uvm_config_db#(virtual frame_formatter_packet_interface)::get(this,"*","packet_vif",packet_vif))
            `uvm_fatal(get_full_name(),{"unable to get interface in packet_monitor","packet_vif"})
        if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
            `uvm_fatal(get_full_name(),"No clk interface found")
  
    endfunction
  
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
       	       
        `uvm_info(get_type_name(),$sformatf("inside packet_monitor"),UVM_MEDIUM)

        // convert pin level to transaction level
        forever begin
        
            @(posedge clk_vif.Frame_Formatter_TOP_clk);
       
     	    seq_item_inst = frame_formatter_packet_seq_item::type_id::create("seq_item_inst",this);
     	    seq_item_inst.in_sop            = packet_vif.in_sop;
     	    seq_item_inst.in_eop            = packet_vif.in_eop;
            seq_item_inst.sync_fifo_wr_en   = packet_vif.sync_fifo_wr_en;
            seq_item_inst.sync_fifo_wr_data =  packet_vif.sync_fifo_wr_data;
	        seq_item_inst.Frame_Formatter_TOP_rstn = packet_vif.Frame_Formatter_TOP_rstn;     	    

            `uvm_info(get_type_name(),$sformatf("in_sop= %b,in_eop=%b,sync_fifo_wr_en=%d,sync_fifo_wr_data=%32h",seq_item_inst.in_sop,seq_item_inst.in_eop,seq_item_inst.sync_fifo_wr_en,seq_item_inst.sync_fifo_wr_data),UVM_MEDIUM)
      
            ap.write(seq_item_inst);
      
        
    end

  endtask
endclass


