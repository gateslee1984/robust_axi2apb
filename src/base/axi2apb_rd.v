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


module  axi2apb_rd (
);

   input 		clk;
   input 		reset_n;

   input		psel; 
   input		penable; 
   input		pwrite; 
   input [31:0]		paddr; 
   input [31:0]		pwdata; 
   output [31:0]	prdata; 
   output		pslverr; 
   output		pready; 

   input                cmd_err;
   input [4-1:0]        cmd_id;
   output               finish_rd;
   
   output [3:0]       RGROUP_APB_AXI_R_ID;
   output [31:0]      RGROUP_APB_AXI_R_DATA;
   output [1:0]       RGROUP_APB_AXI_R_RESP;
   output             RGROUP_APB_AXI_R_LAST;
   output             RGROUP_APB_AXI_R_VALID;
   input              RGROUP_APB_AXI_R_READY;
   
   parameter              RESP_OK     = 2'b00;
   parameter              RESP_SLVERR = 2'b10;
   parameter              RESP_DECERR = 2'b11;
   
   reg	 [3:0]       RGROUP_APB_AXI_R_ID;
   reg	 [31:0]      RGROUP_APB_AXI_R_DATA;
   reg	 [1:0]       RGROUP_APB_AXI_R_RESP;
   reg	             RGROUP_APB_AXI_R_LAST;
   reg	             RGROUP_APB_AXI_R_VALID;
   
   
   assign                 finish_rd = RGROUP_APB_AXI_R_VALID & RGROUP_APB_AXI_R_READY & RGROUP_APB_AXI_R_LAST;
   
   always @(posedge clk )
     if (~reset_n)
	   begin
   		RGROUP_APB_AXI_R_ID <= #1 {4{1'b0}};
   		RGROUP_APB_AXI_R_DATA <= #1 {31{1'b0}};
   		RGROUP_APB_AXI_R_RESP <= #1 {2{1'b0}};
   		RGROUP_APB_AXI_R_LAST <= #1 {1{1'b0}};
   		RGROUP_APB_AXI_R_VALID <= #1 {1{1'b0}};
	   end
	 else if (finish_rd)
	   begin
   		RGROUP_APB_AXI_R_ID <= #1 {4{1'b0}};
   		RGROUP_APB_AXI_R_DATA <= #1 {31{1'b0}};
   		RGROUP_APB_AXI_R_RESP <= #1 {2{1'b0}};
   		RGROUP_APB_AXI_R_LAST <= #1 {1{1'b0}};
   		RGROUP_APB_AXI_R_VALID <= #1 {1{1'b0}};
	   end
	 else if (psel & penable & (~pwrite) & pready)
	   begin
	        RGROUP_APB_AXI_R_ID    <= #1 cmd_id;
		RGROUP_APB_AXI_R_DATA  <= #1 prdata;
		RGROUP_APB_AXI_R_RESP  <= #1 cmd_err ? RESP_SLVERR : pslverr ? RESP_DECERR : RESP_OK;
		RGROUP_APB_AXI_R_LAST  <= #1 1'b1;
		RGROUP_APB_AXI_R_VALID <= #1 1'b1;
	   end
	   
endmodule

   
