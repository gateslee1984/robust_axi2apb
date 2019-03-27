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

module  axi2apb(
   clk,
   reset_n,
   AWGROUP_APB_AXI_A_ID,
   AWGROUP_APB_AXI_A_ADDR,
   AWGROUP_APB_AXI_A_LEN,
   AWGROUP_APB_AXI_A_SIZE,
   AWGROUP_APB_AXI_A_VALID,
   AWGROUP_APB_AXI_A_READY,
   ARGROUP_APB_AXI_A_ID,
   ARGROUP_APB_AXI_A_ADDR,
   ARGROUP_APB_AXI_A_LEN,
   ARGROUP_APB_AXI_A_SIZE,
   ARGROUP_APB_AXI_A_VALID,
   ARGROUP_APB_AXI_A_READY,
   WGROUP_APB_AXI_W_ID,
   WGROUP_APB_AXI_W_DATA,
   WGROUP_APB_AXI_W_STRB,
   WGROUP_APB_AXI_W_LAST,
   WGROUP_APB_AXI_W_VALID,
   WGROUP_APB_AXI_W_READY,
   BGROUP_APB_AXI_B_ID,
   BGROUP_APB_AXI_B_RESP,
   BGROUP_APB_AXI_B_VALID,
   BGROUP_APB_AXI_B_READY,
   RGROUP_APB_AXI_R_ID,
   RGROUP_APB_AXI_R_DATA,
   RGROUP_APB_AXI_R_RESP,
   RGROUP_APB_AXI_R_LAST,
   RGROUP_APB_AXI_R_VALID,
   RGROUP_APB_AXI_R_READY,
   psel,
   penable,
   pwrite,
   paddr,
   pwdata,
   prdata
);

   input              clk;
   input              reset_n;
 
   input  [3:0]       AWGROUP_APB_AXI_A_ID;
   input  [31:0]      AWGROUP_APB_AXI_A_ADDR;
   input  [3:0]       AWGROUP_APB_AXI_A_LEN;
   input  [1:0]       AWGROUP_APB_AXI_A_SIZE;
   input              AWGROUP_APB_AXI_A_VALID;
   output             AWGROUP_APB_AXI_A_READY;
   input  [3:0]       ARGROUP_APB_AXI_A_ID;
   input  [31:0]      ARGROUP_APB_AXI_A_ADDR;
   input  [3:0]       ARGROUP_APB_AXI_A_LEN;
   input  [1:0]       ARGROUP_APB_AXI_A_SIZE;
   input              ARGROUP_APB_AXI_A_VALID;
   output             ARGROUP_APB_AXI_A_READY;
   input  [3:0]       WGROUP_APB_AXI_W_ID;
   input  [31:0]      WGROUP_APB_AXI_W_DATA;
   input  [3:0]       WGROUP_APB_AXI_W_STRB;
   input              WGROUP_APB_AXI_W_LAST;
   input              WGROUP_APB_AXI_W_VALID;
   output             WGROUP_APB_AXI_W_READY;
   output [3:0]	      BGROUP_APB_AXI_B_ID;
   output [1:0]	      BGROUP_APB_AXI_B_RESP;
   output	      BGROUP_APB_AXI_B_VALID;
   input	      BGROUP_APB_AXI_B_READY;
   output [3:0]	      RGROUP_APB_AXI_R_ID;
   output [31:0]      RGROUP_APB_AXI_R_DATA;
   output [1:0]	      RGROUP_APB_AXI_R_RESP;
   output	      RGROUP_APB_AXI_R_LAST;
   output	      RGROUP_APB_AXI_R_VALID;
   input	      RGROUP_APB_AXI_R_READY;

   //apb slaves
   input	      psel;
   input	      penable;
   input	      pwrite;
   input  [31:0]      paddr;
   input  [31:0]      pwdata;
   output [31:0]      prdata;
   output             pslverr;
   output             pready;

   wire               psel;
   wire               penable;
   wire               pwrite;
   wire   [31:0]      paddr;
   wire   [31:0]      pwdata;
   wire   [31:0]      prdata;
   wire               pslverr;
   wire               pready;

   
   //outputs of cmd
   wire                   cmd_empty;
   wire                   cmd_read;
   wire [4-1:0]     cmd_id;
   wire [32-1:0]   cmd_addr;
   wire                   cmd_err;
   
   //outputs of rd / wr
   wire                   finish_wr;
   wire                   finish_rd;
   
   
   assign                 paddr  = cmd_addr;
   assign                 pwdata = WGROUP_APB_AXI_W_DATA;

   
     axi2apb_cmd axi2apb_cmd(
	      	   .clk(clk),
	      	   .reset_n(reset_n),
                   .AWGROUP_APB_AXI_A_ID(AWGROUP_APB_AXI_A_ID),
                   .AWGROUP_APB_AXI_A_ADDR(AWGROUP_APB_AXI_A_ADDR),
                   .AWGROUP_APB_AXI_A_LEN(AWGROUP_APB_AXI_A_LEN),
                   .AWGROUP_APB_AXI_A_SIZE(AWGROUP_APB_AXI_A_SIZE),
                   .AWGROUP_APB_AXI_A_VALID(AWGROUP_APB_AXI_A_VALID),
                   .AWGROUP_APB_AXI_A_READY(AWGROUP_APB_AXI_A_READY),
                   .ARGROUP_APB_AXI_A_ID(ARGROUP_APB_AXI_A_ID),
                   .ARGROUP_APB_AXI_A_ADDR(ARGROUP_APB_AXI_A_ADDR),
                   .ARGROUP_APB_AXI_A_LEN(ARGROUP_APB_AXI_A_LEN),
                   .ARGROUP_APB_AXI_A_SIZE(ARGROUP_APB_AXI_A_SIZE),
                   .ARGROUP_APB_AXI_A_VALID(ARGROUP_APB_AXI_A_VALID),
                   .ARGROUP_APB_AXI_A_READY(AWGROUP_APB_AXI_A_READY),
	      	   .finish_wr(finish_wr),
	      	   .finish_rd(finish_rd),
	      	   .cmd_empty(cmd_empty),
	      	   .cmd_read(cmd_read),
	      	   .cmd_id(cmd_id),
	      	   .cmd_addr(cmd_addr),
	      	   .cmd_err(cmd_err)
                         );

   
     axi2apb_rd axi2apb_rd(
		 .clk(clk),
		 .reset_n(reset_n),
   		 .psel(psel),
   		 .penable(penable),
   		 .pwrite(pwrite),
   		 .paddr(paddr),
   		 .pwdata(pwdata),
   		 .prdata(prdata),
   		 .pslverr(pslverr),
   		 .pready(pready),
		 .cmd_err(cmd_err),
		 .cmd_id(cmd_id),
		 .finish_rd(finish_rd),
   		 .RGROUP_APB_AXI_R_ID(RGROUP_APB_AXI_R_ID),
   		 .RGROUP_APB_AXI_R_DATA(RGROUP_APB_AXI_R_DATA),
   		 .RGROUP_APB_AXI_R_RESP(RGROUP_APB_AXI_R_RESP),
   		 .RGROUP_APB_AXI_R_LAST(RGROUP_APB_AXI_R_LAST),
   		 .RGROUP_APB_AXI_R_VALID(RGROUP_APB_AXI_R_VALID),
   		 .RGROUP_APB_AXI_R_READY(RGROUP_APB_AXI_R_READY),
		 );
   
     axi2apb_wr axi2apb_wr(
		 .clk(clk),
		 .reset_n(reset_n),
   		 .psel(psel),
   		 .penable(penable),
   		 .pwrite(pwrite),
   		 .paddr(paddr),
   		 .pwdata(pwdata),
   		 .prdata(prdata),
	         .cmd_err(cmd_err),
	         .cmd_id(cmd_id),
	         .finish_wr(finish_wr),
	         .WGROUP_APB_AXI_W(WGROUP_APB_AXI_W),
	         .BGROUP_APB_AXI_B(BGROUP_APB_AXI_B),
                 .WGROUP_APB_AXI_W_ID(WGROUP_APB_AXI_W_ID),
                 .WGROUP_APB_AXI_W_DATA(WGROUP_APB_AXI_W_DATA),
                 .WGROUP_APB_AXI_W_STRB(WGROUP_APB_AXI_W_STRB),
                 .WGROUP_APB_AXI_W_LAST(WGROUP_APB_AXI_W_LAST),
                 .WGROUP_APB_AXI_W_VALID(WGROUP_APB_AXI_W_VALID),
                 .WGROUP_APB_AXI_W_READY(WGROUP_APB_AXI_W_READY),
                 .BGROUP_APB_AXI_B_ID(BGROUP_APB_AXI_B_ID),
                 .BGROUP_APB_AXI_B_RESP(BGROUP_APB_AXI_B_RESP),
                 .BGROUP_APB_AXI_B_VALID(BGROUP_APB_AXI_B_VALID),
                 .BGROUP_APB_AXI_B_READY(BGROUP_APB_AXI_B_READY),
		);
      

   
     axi2apb_ctrl axi2apb_ctrl(
					     .clk(clk),
					     .reset_n(reset_n),
					     .finish_wr(finish_wr),			
					     .finish_rd(finish_rd),
					     .cmd_empty(cmd_empty),
					     .cmd_read(cmd_read),
					     .WVALID(WGROUP_APB_AXI_W_VALID),
					     .psel(psel),
					     .penable(penable),
					     .pwrite(pwrite),
					     .pready(pready)
					     );


endmodule


