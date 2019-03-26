class frame_formatter_fifo_driver extends uvm_driver#(frame_formatter_fifo_seq_item);
    
    // factory registration 
    `uvm_component_utils(frame_formatter_fifo_driver)
  
   // creating interface and sequence item handle
    virtual frame_formatter_fifo_interface fifo_vif;
    virtual frame_formatter_clk_interface clk_vif;
    frame_formatter_fifo_seq_item seq_inst;
  

    // constructor 
    function new(string name= "frame_formatter_fifo_driver",uvm_component parent);
        super.new(name,parent);
    endfunction 


      
    // build phase   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       // seq_inst = frame_formatter_seq_item::type_id::create("seq_inst",this);
        if(!uvm_config_db#(virtual frame_formatter_fifo_interface)::get(this,"*","fifo_vif",fifo_vif))
            `uvm_fatal(get_full_name(),"No fifo interface found")

        if(!uvm_config_db#(virtual frame_formatter_clk_interface)::get(this,"*","clk_vif",clk_vif))
            `uvm_fatal(get_full_name(),"No clk interface found")

    endfunction



    task run_phase(uvm_phase phase);
        super.run_phase(phase);
      	`uvm_info(get_type_name(),"Inside fifo driver body",UVM_LOW)
        @(posedge clk_vif.Frame_Formatter_TOP_clk);
        // @(posedge clk_vif.Frame_Formatter_TOP_clk);
     
        fifo_vif.async_fifo_rd_en                     <= 0;
     
        forever begin 
            seq_item_port.get_next_item(seq_inst);
            //@(posedge clk_vif.Frame_Formatter_TOP_clk);
            `uvm_info(get_type_name(),"Inside fifo driver loop",UVM_LOW)
       
         
            fifo_vif.async_fifo_rd_en <= seq_inst.async_fifo_rd_en;
                
            seq_item_port.item_done();
            
            `uvm_info(get_type_name(),"fifo driver loop reahcing end",UVM_LOW)
        end 
            `uvm_info(get_type_name(),"fifo driver loop end",UVM_LOW) 
        
    endtask
endclass
