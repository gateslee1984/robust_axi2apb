<##//////////////////////////////////////////////////////////////////
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


module  axi2apb_wr (
	);

   input 	      clk;
   input 	      reset_n;
   
   input              psel;
   input              penable;
   input              pwrite;
   input  [31:0]      paddr;
   input  [31:0]      pwdata;
   output [31:0]      prdata;
   output             pslverr;
   output             pready;
      
   input              cmd_err;
   input [4-1:0]      cmd_id;
   output             finish_wr;
   
   input  [3:0]       WGROUP_APB_AXI_W_ID;
   input  [31:0]      WGROUP_APB_AXI_W_DATA;
   input  [3:0]       WGROUP_APB_AXI_W_STRB;
   input              WGROUP_APB_AXI_W_LAST;
   input              WGROUP_APB_AXI_W_VALID;
   output             WGROUP_APB_AXI_W_READY;
   output [3:0]       BGROUP_APB_AXI_B_ID;
   output [1:0]       BGROUP_APB_AXI_B_RESP;
   output             BGROUP_APB_AXI_B_VALID;
   input              BGROUP_APB_AXI_B_READY;

   
   parameter              RESP_OK     = 2'b00;
   parameter              RESP_SLVERR = 2'b10;
   parameter              RESP_DECERR = 2'b11;
   
   reg [3:0]       BGROUP_APB_AXI_B_ID;
   reg [1:0]       BGROUP_APB_AXI_B_RESP;
   reg             BGROUP_APB_AXI_B_VALID;
   
   
   assign                 finish_wr = BGROUP_APB_AXI_B_VALID & BGROUP_APB_AXI_B_READY;
   
   assign                 WGROUP_APB_AXI_W_READY = psel & penable & pwrite & pready;
   
   always @(posedge clk )
     if (~reset_n)
	   begin
   		BGROUP_APB_AXI_B_ID <= #1 {4{1'b0}};
   		BGROUP_APB_AXI_B_RESP <= #1 {2{1'b0}};
   		BGROUP_APB_AXI_B_VALID <= #1 {1{1'b0}};
	   end
	 else if (finish_wr)
	   begin
   		BGROUP_APB_AXI_B_ID <= #1 {4{1'b0}};
   		BGROUP_APB_AXI_B_RESP <= #1 {2{1'b0}};
   		BGROUP_APB_AXI_B_VALID <= #1 {1{1'b0}};
	   end
	 else if (psel & penable & pwrite & pready)
	   begin
	     	BGROUP_APB_AXI_B_ID    <= #1 cmd_id;
	     	BGROUP_APB_AXI_B_RESP  <= #1 cmd_err ? RESP_SLVERR : pslverr ? RESP_DECERR : RESP_OK;
	     	BGROUP_APB_AXI_B_VALID <= #1 1'b1;
	   end
	   
endmodule

   
