  class frame_formatter_base_test extends uvm_test;
 
  // factory registration 
    
  `uvm_component_utils(frame_formatter_base_test)

   // creating env and sequence handle
   
   frame_formatter_fifo_sequence    fifo_sequence_inst;
   frame_formatter_header_sequence  header_sequence_inst;
   frame_formatter_packet_sequence  packet_sequence_inst;


   frame_formatter_fifo_seq_item    fifo_seq_item_inst;
   frame_formatter_header_seq_item  header_seq_item_inst;
   frame_formatter_packet_seq_item  packet_seq_item_inst;
   frame_formatter_env env_inst;
    
  //constructor
   function new(string name = "frame_formatter_base_test",uvm_component parent);
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
    `uvm_info(get_name(),$sformatf("inside the base test"),UVM_MEDIUM)
     fifo_sequence_inst= frame_formatter_fifo_sequence ::type_id::create("fifo_sequence_inst");
     packet_sequence_inst= frame_formatter_packet_sequence ::type_id::create("packet_sequence_inst");
     header_sequence_inst= frame_formatter_header_sequence ::type_id::create("heaader_sequence_inst");

    `uvm_info(get_type_name(),"inside test run body",UVM_LOW)

   repeat(10)
      #1570;
    
   for(int i=0; i<10;i++) begin

      
       fifo_seq_item_inst =   frame_formatter_fifo_seq_item::type_id::create("fifo_seq_item_inst");
       packet_seq_item_inst = frame_formatter_packet_seq_item::type_id::create("packet_seq_item_inst");
      header_seq_item_inst = frame_formatter_header_seq_item::type_id::create("header_seq_item_inst");
        
       `uvm_info(get_type_name(),"inside test run for loop body",UVM_LOW)


    
      fifo_seq_item_inst.sync_fifo_wr_data = i;
 
      fifo_seq_item_inst.sync_fifo_wr_en =1;
      
      fifo_seq_item_inst.async_fifo_rd_en = 1;
       
      packet_seq_item_inst.in_sop =1;
      packet_seq_item_inst.in_eop =0;
     
        header_seq_item_inst.preamble=5;
        header_seq_item_inst.in_bypass_en=1;
        header_seq_item_inst.source_addr=10;
	header_seq_item_inst.dest_addr=20;
	header_seq_item_inst.Type=2;
	header_seq_item_inst.vlan_tag=15;
	header_seq_item_inst.vlan_tag_en=1;
       `uvm_info(get_type_name(),"inside test  for loop body after assigning val",UVM_LOW)
  //    `uvm_info(get_type_name(),$sformatf("sync_fifo_wr_en= %b,fifo_vif.sync_fifo_wr_data=%d,async_fifo_rd_en =%b",  fifo_seq_item_inst.sync_fifo_wr_en,fifo_seq_item_inst.sync_fifo_wr_data,fifo_seq_item_inst.async_fifo_rd_en ),UVM_MEDIUM)

	fifo_sequence_inst.seq_item_inst = fifo_seq_item_inst;
        packet_sequence_inst.seq_item_inst = packet_seq_item_inst;
        header_sequence_inst.seq_item_inst = header_seq_item_inst;

    //   `uvm_info(get_type_name(),$sformatf("sequence_instsync_fifo_wr_en= %b,fifo_vif.sync_fifo_wr_data=%d,async_fifo_rd_en =%b", fifo_sequence_inst.seq_item_inst.sync_fifo_wr_en,fifo_sequence_inst.seq_item_inst.sync_fifo_wr_data,fifo_sequence_inst.seq_item_inst.async_fifo_rd_en ),UVM_MEDIUM)
/*
	fifo_sequence_inst.start_item(fifo_seq_item_inst);
        packet_sequence_inst.start_item(packet_seq_item_inst);
	header_sequence_inst.start_item(header_seq_item_inst);

	fifo_sequence_inst.finish_item(fifo_seq_item_inst);
        packet_sequence_inst.finish_item(packet_seq_item_inst);
	header_sequence_inst.finish_item(header_seq_item_inst); */


    `uvm_info(get_type_name(),"inside test  before start sequence on sequencer",UVM_LOW)

    fifo_sequence_inst.start(env_inst.fifo_agt_inst.seqr_inst);
    `uvm_info(get_type_name(),"inside test after start fifo sequencer",UVM_LOW)
     packet_sequence_inst.start(env_inst.packet_agt_inst.seqr_inst);
     `uvm_info(get_type_name(),"inside test after start packet sequencer",UVM_LOW)
     header_sequence_inst.start(env_inst.header_agt_inst.seqr_inst);
     `uvm_info(get_type_name(),"inside test after start header sequencer",UVM_LOW)
  `uvm_info(get_type_name(),"inside test after start sequencer",UVM_LOW)

    #1570;



   end






    phase.drop_objection(this);
    uvm_test_done.set_drain_time(this,10000);
  endtask

 virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology(); // This will print the UVM topology
  endfunction


endclass
