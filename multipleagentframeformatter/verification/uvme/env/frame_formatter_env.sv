class frame_formatter_env extends uvm_env;
    
    // factory registration 
    `uvm_component_utils(frame_formatter_env)
             
    // creating agent scoreboard handle
    frame_formatter_packet_agent packet_agt_inst;
    frame_formatter_header_agent header_agt_inst;
    frame_formatter_fifo_agent  fifo_agt_inst;
    frame_formatter_scoreboard scb_inst;



    coverage_model_fifo  fifo_cov;
    coverage_model_packet  packet_cov;
    coverage_model_header  header_cov;



    // constructor 
    function new(string name = "frame_formatter_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    // build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        packet_agt_inst = frame_formatter_packet_agent::type_id::create("packet_agt_inst",this);
        header_agt_inst = frame_formatter_header_agent::type_id::create("header_agt_inst",this);
        fifo_agt_inst = frame_formatter_fifo_agent::type_id::create("fifo_agt_inst",this);

        fifo_cov  = coverage_model_fifo::type_id::create("fifo_cov",this);
        packet_cov  = coverage_model_packet::type_id::create("packet_cov",this);
        header_cov  = coverage_model_header::type_id::create("header_cov",this);

        scb_inst = frame_formatter_scoreboard::type_id::create("scb_inst",this);
     endfunction 


     function void connect_phase(uvm_phase phase);
         // Connect packet monitor to scoreboard 
         packet_agt_inst.mon_inst.ap.connect(scb_inst.packet_ap);
         
         // Connect header monior to scoreboard
         header_agt_inst.mon_inst.ap.connect(scb_inst.header_ap);

         // Connect fifo monitor to scoreboard
         fifo_agt_inst.mon_inst.ap.connect(scb_inst.fifo_ap);

         // Connect fifo montor to fifo coverage 
         fifo_agt_inst.mon_inst.ap.connect(fifo_cov.analysis_export);

         // Connect packet monitor to packet coverage 
         packet_agt_inst.mon_inst.ap.connect(packet_cov.analysis_export);

         // Connect header monitor to header coverage 
         header_agt_inst.mon_inst.ap.connect(header_cov.analysis_export);

    endfunction 

endclass
