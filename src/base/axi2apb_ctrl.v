//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>


module  axi2apb_ctrl (
         clk,
         reset_n,
         finish_wr,
         finish_rd,
         cmd_empty,
         cmd_read,
         WVALID,
   	 psel,
   	 penable,
   	 pwrite,
   	 pready
);


   input        clk;
   input        reset_n;

   input        finish_wr;
   input        finish_rd;
   
   input        cmd_empty;
   input        cmd_read;
   input        WVALID;

   output 	psel;
   output 	penable;
   output 	pwrite;
   input 	pready;
   
   wire	 	wstart;
   wire         rstart;
   
   reg          busy;
   reg          psel;
   reg 		penable;
   reg 		pwrite;
   wire         pack;
   wire         cmd_ready;
   

   assign                     cmd_ready = (~busy) & (~cmd_empty);
   assign                     wstart = cmd_ready & (~cmd_read) & (~psel) & WVALID;
   assign                     rstart = cmd_ready & cmd_read & (~psel);
   
   assign             pack = psel & penable & pready;
   
   always @(posedge clk )
     if (~reset_n)
       busy <= #1 1'b0;
     else if (psel)
       busy <= #1 1'b1;
     else if (finish_rd | finish_wr)
       busy <= #1 1'b0;
   
   always @(posedge clk )
     if (~reset_n)
       psel <= #1 1'b0;
     else if (pack)
       psel <= #1 1'b0;
     else if (wstart | rstart)
       psel <= #1 1'b1;
   
   always @(posedge clk )
     if (~reset_n)
       penable <= #1 1'b0;
     else if (pack)
       penable <= #1 1'b0;
     else if (psel)
       penable <= #1 1'b1;

   always @(posedge clk )
     if (~reset_n)
       pwrite  <= #1 1'b0;
     else if (pack)
       pwrite  <= #1 1'b0;
     else if (wstart)
       pwrite  <= #1 1'b1;
   

endmodule

   
