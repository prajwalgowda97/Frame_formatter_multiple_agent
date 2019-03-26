class frame_formatter_fifo_monitor extends uvm_monitor;


    // factory registration 
    `uvm_component_utils(frame_formatter_fifo_monitor)
     
   // creating handle of interface and sequence item
          

    virtual frame_formatter_fifo_interface fifo_vif;
    virtual frame_formatter_clk_interface clk_vif;
    frame_formatter_fifo_seq_item seq_item_inst;
    uvm_analysis_port #(frame_formatter_fifo_seq_item) ap;


    //constructor
    function new(string name="frame_formatter_fifo_monitor",uvm_component parent);
        super.new(name,parent);
        ap = new("ap",this);
    endfunction
      

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //gettinsg virtual interface
        if(!uvm_config_db#(virtual frame_formatter_fifo_interface)::get(this,"*","fifo_vif",fifo_vif))
           `uvm_fatal(get_full_name(),{"unable to get interface in fifo_monitor","fifo_vif"})
        if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
           `uvm_fatal(get_full_name(),"No clk interface found")
       
      endfunction
 
      task run_phase(uvm_phase phase);
          super.run_phase(phase);                        
         `uvm_info(get_type_name(),$sformatf("inside fifo_monitor"),UVM_MEDIUM)

         // convert pin level to transaction level
         forever begin
                  
             @(posedge clk_vif.async_fifo_rd_clk);

             
             seq_item_inst = frame_formatter_fifo_seq_item::type_id::create("seq_item_inst",this);
             seq_item_inst.async_fifo_full    = fifo_vif.async_fifo_full;
             seq_item_inst.async_fifo_empty   = fifo_vif.async_fifo_empty;
             seq_item_inst.async_fifo_rd_data = fifo_vif.async_fifo_rd_data;
             seq_item_inst.async_fifo_rd_en   = fifo_vif.async_fifo_rd_en;
             seq_item_inst.async_almost_full  = fifo_vif.async_almost_full;
             seq_item_inst.async_almost_empty = fifo_vif.async_almost_empty;
             seq_item_inst.out_sop            = fifo_vif.out_sop;
             seq_item_inst.out_eop            = fifo_vif.out_eop;
     
             seq_item_inst.sync_fifo_full      = fifo_vif.sync_fifo_full;
             seq_item_inst.sync_fifo_empty     = fifo_vif.sync_fifo_empty;
             seq_item_inst.sync_almost_full    = fifo_vif.sync_almost_full;
             seq_item_inst.sync_almost_empty   = fifo_vif.sync_almost_empty;

             seq_item_inst.sync_overflow       =   fifo_vif.sync_overflow;
             seq_item_inst.async_overflow      =   fifo_vif.async_overflow;
        
             seq_item_inst.sync_underflow      =   fifo_vif.sync_overflow;
             seq_item_inst.async_underflow     =   fifo_vif.async_underflow;

             `uvm_info(get_type_name(),$sformatf("outsop=%d,outeop=%d,asyn_fifo_full= %b,async_fifo_empty=%b,async_rdata=%32h, async_rd_en=%d,seq_item_inst.async_almost_full",fifo_vif.out_sop,fifo_vif.out_eop,fifo_vif.async_fifo_full,fifo_vif.async_fifo_empty,fifo_vif.async_fifo_rd_data,fifo_vif.async_fifo_rd_en,fifo_vif.async_almost_full),UVM_MEDIUM)
      
             ap.write(seq_item_inst);
      
        
    end

  endtask
endclass

