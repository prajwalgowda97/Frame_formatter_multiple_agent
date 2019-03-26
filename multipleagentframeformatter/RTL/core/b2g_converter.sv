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
* File Name : b2g_converter.sv

* Purpose :

* Creation Date : 10-02-2023

* Last Modified : Fri 10 Feb 2023 03:16:41 AM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

module b2g_converter #(parameter WIDTH = 6)                 // binary to gray code converter
                        (output bit [WIDTH-1:0] grey,
                         input bit [WIDTH-1:0] binary);

    assign grey[WIDTH-1] = binary[WIDTH-1];

    genvar i;
    generate 
        for(i = 0;i<WIDTH-1;i++) begin : binary_to_grey
            assign grey[i] = binary[i] ^ binary[i+1];
            end
    endgenerate 
endmodule

