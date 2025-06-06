class frame_formatter_packet_agent extends uvm_agent;
    `uvm_component_utils(frame_formatter_packet_agent)
 
     // create driver
     frame_formatter_packet_driver drv_inst;
     frame_formatter_packet_seqr seqr_inst;
     frame_formatter_packet_monitor mon_inst;


     // constructor 
     function new(string name= "frame_formatter_packet_agent",uvm_component parent);
         super.new(name, parent);
     endfunction 

     // build phase 
     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          drv_inst= frame_formatter_packet_driver::type_id::create("drv_inst",this);
          seqr_inst= frame_formatter_packet_seqr::type_id::create("seqr_inst",this);
          mon_inst= frame_formatter_packet_monitor::type_id::create("mon_inst",this);
     endfunction 
    
    // connect phase
     function void connect_phase(uvm_phase phase);
         super.connect_phase(phase);
         // Connect driver to sequencer
         drv_inst.seq_item_port.connect(seqr_inst.seq_item_export);
    endfunction 
endclass
