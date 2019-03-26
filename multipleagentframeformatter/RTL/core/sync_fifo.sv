module sync_fifo #(parameter ADD_WIDTH  = 5 ,
              parameter DATA_WIDTH = 32,
              parameter DATA_DEPTH = 32,
              parameter ALMOST     = 2)
              (output logic [DATA_WIDTH-1:0] rd_data        ,
               output logic                  write_full     ,
               output logic                  read_empty     ,
               output logic                  almost_full    ,
               output logic                  almost_empty   ,
               output logic                  overflow       ,
               output logic                  underflow      ,
               output logic [ADD_WIDTH:0]    rd_lvl         ,
               output logic [ADD_WIDTH:0]    wr_lvl         ,
               input  logic [DATA_WIDTH-1:0] wr_data        ,
               input  logic                  rd_en          ,
               input  logic                  wr_en          ,
               input  logic                  clk            ,
               input  logic                  rst_n          ,
               input  logic                  sw_rst         ,

               input  logic                  in_sop         ,
               input  logic                  in_eop         ,
               output logic [6:0]            pkt_len        ,
               output logic                  ff_in_sop       ,
               output logic                  ff_in_eop
               );
        

    bit   [ADD_WIDTH-1:0] wr_ptr;
    logic [ADD_WIDTH-1:0] rd_ptr;
    logic                 wr_valid;
    logic                 rd_valid;
    logic                 wr_full;
    logic                 rd_empty;
    logic [6:0]           count;
  //  logic [6:0]           count1;
    logic                 in_eop_d1;

    assign write_full = wr_full;
    assign read_empty = rd_empty;
    
    logic [DATA_WIDTH + 1 :0] fifo_mem [DATA_DEPTH-1 : 0];
    logic [ADD_WIDTH:0] fifo_counter;                             // used to count the number of elements in the FIFO
    
        always_ff@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    begin
                        in_eop_d1 <= 1'b0;
                    end

                else if(sw_rst)
                    begin
                        in_eop_d1 <= 1'b0;
                    end

                else
                    begin
                        in_eop_d1 <= in_eop;
                    end
            end

    ///////// calculate packet length from in_sop to in_eop when write enable asserted //////////
        always_ff@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    begin
                        count <= 7'd0;
                    end
                else if(sw_rst)
                    begin
                        count <= 7'd0;
                    end

                else if(wr_en)
                    begin
                        count <= count + 7'd1;
                    end

                else if(in_eop_d1) 
                    begin
                        count <= 7'd0;
                    end
            end

        

        always_ff@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    begin
                        pkt_len <= 7'd0;
                    end

                else if(sw_rst)
                    begin
                        pkt_len <= 7'd0;
                    end

                else if(in_eop_d1)
                    begin
                        pkt_len <= count;
                    end                                                                              
            end

   // logic [DATA_WIDTH-1:0] reg1,reg2;

        ///// logic for read pointer 

     always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            begin
                rd_ptr <= {ADD_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                rd_ptr <= {ADD_WIDTH{1'b0}};
            end

        else if(rd_en && !rd_empty) 
            begin
                rd_ptr <= rd_ptr + {{(ADD_WIDTH-1){1'b0}},1'b1};
            end

        else 
            begin
                rd_ptr <= rd_ptr;
            end
             
     end

     //// logic for write pointer 

     
     assign wr_valid = (wr_en && !wr_full) ? 1'b1 : 1'b0;
     assign rd_valid = (rd_en && !rd_empty) ? 1'b1 : 1'b0;

     always_ff @(posedge clk or negedge rst_n) 
     begin
        if(!rst_n) 
            begin
                wr_ptr <= {ADD_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                wr_ptr <= {ADD_WIDTH{1'b0}};
            end

        else if(wr_valid) 
            begin
                wr_ptr <= wr_ptr +{{(ADD_WIDTH-1){1'b0}},1'b1};
            end

        else 
            begin
                wr_ptr <= wr_ptr;
            end

     end

       

        always @(posedge clk or negedge rst_n) begin                        // to count elements in FIFO
            if(!rst_n) begin
                fifo_counter <= {(ADD_WIDTH+1){1'b0}};
            end

            else if(sw_rst)
                begin
                    fifo_counter <= {(ADD_WIDTH+1){1'b0}};
                end
            else if((wr_valid) && (rd_valid)) 
                begin                
                    fifo_counter <= fifo_counter;
                end
            else if(wr_valid) 
                begin
                    fifo_counter <= fifo_counter + {{ADD_WIDTH{1'b0}},1'b1};
                end
            else if(rd_valid) 
                begin
                    fifo_counter <= fifo_counter - {{ADD_WIDTH{1'b0}},1'b1};
                end
            else 
                begin
                    fifo_counter <= fifo_counter;
                end
        end


    /*

     always_ff @(posedge clk or negedge rst_n) begin           // when read is enabled, storing data to reg2 from the FIFO
        if(!rst_n) 
            begin
                reg2 <= {DATA_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                reg2 <= {DATA_WIDTH{1'b0}};
            end
         else if(rd_en && !rd_empty) 
            begin
                reg2 <= fifo_mem[rd_ptr];
            end
        else 
            begin
                reg2 <= reg2;
            end

    end

    always_ff @(posedge clk or negedge rst_n) begin             // when pipe read is enabled, reading the data from the reg2
        if(!rst_n) 
            begin
                rd_data <= {DATA_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                rd_data <= {DATA_WIDTH{1'b0}};
            end

        else if(pipe_rd) 
            begin
                rd_data <= reg2;
            end

     end

    */

    always_ff@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                begin
                    rd_data <= {DATA_WIDTH{1'b0}};
                end

            else if(sw_rst)
                begin
                    rd_data <= {DATA_WIDTH{1'b0}};
                end

            else if(rd_en && !rd_empty)
                begin
                    rd_data <= fifo_mem[rd_ptr][DATA_WIDTH:1];
                    ff_in_sop <= fifo_mem[rd_ptr][DATA_WIDTH+1];
                    ff_in_eop <= fifo_mem[rd_ptr][0];
                end

            else
                begin
                    rd_data <= {(DATA_WIDTH+1){1'b0}};
                    ff_in_sop <= 1'b0;
                    ff_in_eop <= 1'b0;
                end
        end

/*

    always_ff @(posedge clk) begin                  // write data to the FIFO
                
        if(wr_en && !wr_full) 
            begin
                fifo_mem[wr_ptr] <= reg1;
            end
        
            end

    always_ff @(posedge clk or negedge rst_n) begin         // storing write data to reg1 when pipe write is enabled

        if(!rst_n) 
            begin
                reg1 <= {DATA_WIDTH{1'b0}};
            end

        else if(sw_rst)
            begin
                reg1 <= {DATA_WIDTH{1'b0}};
            end

        else if(pipe_wr) 
            begin
                reg1 <= wr_data;
            end

        else 
            begin
                reg1 <= reg1;
            end
    end

  */

    always_ff@(posedge clk)
        begin
            if(wr_en && !wr_full)
                begin
                    fifo_mem[wr_ptr] <= {in_sop,wr_data,in_eop};
                    
                end
        end

    always_ff @(posedge clk or negedge rst_n) begin                    // check for overflow condition
        if(!rst_n) 
            begin
                overflow <= 1'b0;
            end

        else if(sw_rst)
            begin
                overflow <= 1'b0;
            end

        else if(wr_en && wr_full) 
            begin
                overflow <= 1'b1;            
            end

        else 
            begin
                overflow <= 1'b0;
            end
        
    end

    
    always_ff @(posedge clk or negedge rst_n) begin                    // check for underflow condition
        if(!rst_n) 
            begin
                underflow <= 1'b0;
            end

        else if(sw_rst)
            begin
                underflow <= 1'b0;
            end

        else if(rd_en && rd_empty) 
            begin
                underflow <= 1'b1;            
            end

        else 
            begin
                underflow <= 1'b0;
            end
        
    end



    
    assign wr_full = (fifo_counter == {1'b1,{ADD_WIDTH{1'b0}}}) ? 1'b1 : 1'b0;          // to ensure FIFO is full
    assign rd_empty = (fifo_counter == {(ADD_WIDTH+1){1'b0}}) ? 1'b1 : 1'b0;          // to ensure FIFO is empty
    assign almost_full = (fifo_counter >= (DATA_DEPTH - ALMOST)) ? 1'b1 : 1'b0;      // Advance Warning : FIFO has only one space left to write into it
    assign almost_empty = (fifo_counter <= ALMOST) ? 1'b1 : 1'b0;      // Advance Warning : FIFO has only one element to read from it
    assign wr_lvl = fifo_counter;                              // filled spaces in the FIFO
    assign rd_lvl = DATA_DEPTH - fifo_counter;                 // Empty spaces in the FIFO
   
endmodule
