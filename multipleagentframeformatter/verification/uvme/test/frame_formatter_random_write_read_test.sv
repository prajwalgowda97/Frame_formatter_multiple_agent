// This test is for random write_read scenario in between packet.  

class frame_formatter_random_write_read_test extends uvm_test;
 
  // factory registration 
    
  `uvm_component_utils(frame_formatter_random_write_read_test)

   // creating env and sequence handle
   
   frame_formatter_fifo_sequence    fifo_sequence_inst;
   frame_formatter_header_sequence  header_sequence_inst;
   frame_formatter_packet_sequence  packet_sequence_inst;


   frame_formatter_fifo_seq_item    fifo_seq_item_inst;
   frame_formatter_header_seq_item  header_seq_item_inst;
   frame_formatter_packet_seq_item  packet_seq_item_inst;
   frame_formatter_env env_inst;
    
  //constructor
   function new(string name = "frame_formatter_random_write_read_test",uvm_component parent);
     super.new(name,parent);
   endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_inst = frame_formatter_env::type_id::create("env_inst",this); 
    fifo_sequence_inst = frame_formatter_fifo_sequence ::type_id::create("fifo_sequence_inst"); 
    packet_sequence_inst = frame_formatter_packet_sequence ::type_id::create("packet_sequence_inst");
    header_sequence_inst = frame_formatter_header_sequence ::type_id::create("header_sequence_inst");  
  endfunction


  virtual task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_name(),$sformatf("inside test"),UVM_MEDIUM)
     fifo_sequence_inst= frame_formatter_fifo_sequence ::type_id::create("fifo_sequence_inst");
     packet_sequence_inst= frame_formatter_packet_sequence ::type_id::create("packet_sequence_inst");
     header_sequence_inst= frame_formatter_header_sequence ::type_id::create("heaader_sequence_inst");
 
     fifo_seq_item_inst =   frame_formatter_fifo_seq_item::type_id::create("fifo_seq_item_inst");
     packet_seq_item_inst = frame_formatter_packet_seq_item::type_id::create("packet_seq_item_inst");
     header_seq_item_inst = frame_formatter_header_seq_item::type_id::create("header_seq_item_inst");
        
    `uvm_info(get_type_name(),"inside test run body",UVM_LOW)

     repeat(10)
        #1570;
      
     packet_seq_item_inst.Frame_Formatter_TOP_rstn =0;
    // packet_seq_item_inst.Frame_Formatter_TOP_sw_rst =0;


     repeat(10)
       #1570;
     packet_seq_item_inst.Frame_Formatter_TOP_rstn =1;
     packet_seq_item_inst.Frame_Formatter_TOP_sw_rst =0;

     packet_seq_item_inst.sync_fifo_wr_data = $urandom() ;
     packet_seq_item_inst.sync_fifo_wr_en =1;    
     fifo_seq_item_inst.async_fifo_rd_en = 1;
     packet_seq_item_inst.Frame_Formatter_TOP_sw_rst =0;
     packet_seq_item_inst.in_sop =1;
     packet_seq_item_inst.in_eop =0;
     
     header_seq_item_inst.preamble={$urandom(),$urandom()};
     header_seq_item_inst.in_bypass_en=0;
     header_seq_item_inst.source_addr={$urandom() & 16'hffff,$urandom};
     header_seq_item_inst.dest_addr={$urandom() & 16'hffff,$urandom};
     header_seq_item_inst.Type={$urandom() & 16'hffff};
     header_seq_item_inst.vlan_tag=$urandom() ;
     header_seq_item_inst.vlan_tag_en=0;

     fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
     packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
     header_sequence_inst.seq_item_inst = header_seq_item_inst;

     fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
     packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
     header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
     #1570;

     //isop pulse

     packet_seq_item_inst.sync_fifo_wr_data = $urandom() ;
     packet_seq_item_inst.sync_fifo_wr_en =1; 
     packet_seq_item_inst.in_sop =0;
     packet_seq_item_inst.in_eop =0;
     fifo_seq_item_inst.async_fifo_rd_en = 1;

     header_seq_item_inst.vlan_tag_en=0; 
     fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
     packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
     header_sequence_inst.seq_item_inst = header_seq_item_inst;

     fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
     packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
     header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
     #1570;

     for(int i=1;i<5;i++) begin
        packet_seq_item_inst.sync_fifo_wr_data = $urandom();
        packet_seq_item_inst.in_sop =0;
        packet_seq_item_inst.in_eop =0;
     
        fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
        packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
        header_sequence_inst.seq_item_inst = header_seq_item_inst;

        fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
        packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
        header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
        #1570;
     end

   packet_seq_item_inst.sync_fifo_wr_data = $urandom();
   packet_seq_item_inst.in_sop =0;
   packet_seq_item_inst.in_eop =1;
     
   fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
   packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
   header_sequence_inst.seq_item_inst = header_seq_item_inst;

   fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
   packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
   header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
   #1570;
    
   packet_seq_item_inst.sync_fifo_wr_data = $urandom();
   packet_seq_item_inst.in_sop =0;
   packet_seq_item_inst.in_eop =0;
   packet_seq_item_inst.sync_fifo_wr_en =0;
      
   fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
   packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
   header_sequence_inst.seq_item_inst = header_seq_item_inst;

   fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
   packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
   header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);

  repeat(8)
    #1570;

        
 repeat(10) begin
    
      packet_seq_item_inst.sync_fifo_wr_data = $urandom();
      packet_seq_item_inst.sync_fifo_wr_en =1;    
      fifo_seq_item_inst.async_fifo_rd_en = 1;
       
      packet_seq_item_inst.in_sop =1;
      packet_seq_item_inst.in_eop =0;
     
      header_seq_item_inst.preamble={$urandom(),$urandom()};
      header_seq_item_inst.in_bypass_en=0;
      header_seq_item_inst.source_addr={$urandom() & 16'hffff,$urandom};
      header_seq_item_inst.dest_addr={$urandom() & 16'hffff,$urandom};
      header_seq_item_inst.Type={$urandom() & 16'hffff};
      header_seq_item_inst.vlan_tag=$urandom();
      header_seq_item_inst.vlan_tag_en=0;

      fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
      packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
      header_sequence_inst.seq_item_inst = header_seq_item_inst;

      fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
      packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
      header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);

      #1570;

	//isop pulse

      packet_seq_item_inst.sync_fifo_wr_data = $urandom();
      packet_seq_item_inst.sync_fifo_wr_en = $urandom; 
      packet_seq_item_inst.in_sop =0;
      packet_seq_item_inst.in_eop =0;
      fifo_seq_item_inst.async_fifo_rd_en = 1;

      header_seq_item_inst.vlan_tag_en=0; 
      fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
      packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
      header_sequence_inst.seq_item_inst = header_seq_item_inst;

      fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
      packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
      header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
      #1570;

      for(int i=1;i<5;i++) begin
        packet_seq_item_inst.sync_fifo_wr_data = $urandom(); 
 	packet_seq_item_inst.in_sop =0;
        packet_seq_item_inst.in_eop =0;
        packet_seq_item_inst.sync_fifo_wr_en = $urandom; 

        fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
        packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
        header_sequence_inst.seq_item_inst = header_seq_item_inst;

        fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
        packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
        header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
        #1570;
      end

      packet_seq_item_inst.sync_fifo_wr_data = $urandom();
      packet_seq_item_inst.in_sop =0;
      packet_seq_item_inst.in_eop =1;
      packet_seq_item_inst.sync_fifo_wr_en = 1; 
    
      fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
      packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
      header_sequence_inst.seq_item_inst = header_seq_item_inst;

      fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
      packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
      header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
      #1570;
   
      packet_seq_item_inst.sync_fifo_wr_data = $urandom();
      packet_seq_item_inst.in_sop =0;
      packet_seq_item_inst.in_eop =0;
      packet_seq_item_inst.sync_fifo_wr_en =0;
     
      fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
      packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
      header_sequence_inst.seq_item_inst = header_seq_item_inst;

      fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
      packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
      header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);

  repeat(8)
    #1570;

  end

  repeat(12) begin 
     packet_seq_item_inst.in_eop =0;
     packet_seq_item_inst.sync_fifo_wr_en =0;    
     fifo_seq_item_inst.async_fifo_rd_en = 1;

     fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
     packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
     header_sequence_inst.seq_item_inst = header_seq_item_inst;

     fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
     packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
     header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
     #1570;
  end  

    packet_seq_item_inst.in_eop =0;
    packet_seq_item_inst.sync_fifo_wr_en =0;    
    fifo_seq_item_inst.async_fifo_rd_en = 0;

    fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
    packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
    header_sequence_inst.seq_item_inst = header_seq_item_inst;

    fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
    packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
    header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);


    phase.drop_objection(this);
    uvm_test_done.set_drain_time(this,10000);
  endtask


 virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology(); // This will print the UVM topology
  endfunction


endclass







