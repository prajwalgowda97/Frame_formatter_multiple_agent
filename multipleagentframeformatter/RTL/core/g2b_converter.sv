//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////Copyright © 2022 PravegaSemi PVT LTD., All rights reserved//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//All works published under Zilla_Gen_0 by PravegaSemi PVT LTD is copyrighted by the Association and ownership  // 
//of all right, title and interest in and to the works remains with PravegaSemi PVT LTD. No works or documents  //
//published under Zilla_Gen_0 by PravegaSemi PVT LTD may be reproduced,transmitted or copied without the express//
//written permission of PravegaSemi PVT LTD will be considered as a violations of Copyright Act and it may lead //
//to legal action.                                                                                         //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////
* File Name : g2b_converter.sv

* Purpose :

* Creation Date : 10-02-2023

* Last Modified : Fri 10 Feb 2023 03:15:46 AM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

module g2b_converter#(parameter WIDTH = 6)                  // gray to binary code converter
                    (output logic [WIDTH-1:0] binary,
                     input logic [WIDTH-1:0] grey);

    genvar i;
    generate
        for(i=0;i<WIDTH;i++) begin : grey_to_binary
           assign binary[i] = ^(grey >> i);
            end
    endgenerate


endmodule
