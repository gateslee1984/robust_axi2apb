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


module  axi2apb_cmd (
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
   AWGROUP_APB_AXI_A_READY,
   finish_wr,
   finish_rd,
   cmd_empty,
   cmd_read,
   cmd_id,
   cmd_addr,
   cmd_err
);

   input 		  clk;
   input 		  reset_n;

   input [3:0]		  AWGROUP_APB_AXI_A_ID;
   input [31:0]		  AWGROUP_APB_AXI_A_ADDR;
   input [3:0]		  AWGROUP_APB_AXI_A_LEN;
   input [1:0]		  AWGROUP_APB_AXI_A_SIZE;
   input 		  AWGROUP_APB_AXI_A_VALID;
   output 		  AWGROUP_APB_AXI_A_READY;

   input [3:0]		  ARGROUP_APB_AXI_A_ID;
   input [31:0]		  ARGROUP_APB_AXI_A_ADDR;
   input [3:0]		  ARGROUP_APB_AXI_A_LEN;
   input [1:0]		  ARGROUP_APB_AXI_A_SIZE;
   input 		  ARGROUP_APB_AXI_A_VALID;
   output 		  ARGROUP_APB_AXI_A_READY;

   input                  finish_wr;
   input                  finish_rd;
         
   output                 cmd_empty;
   output                 cmd_read;
   output [3-1:0]   	  cmd_id;
   output [31-1:0] 	  cmd_addr;
   output                 cmd_err;
   
   wire	[3:0]		  AWGROUP_APB_AXI_A_ID;
   wire	[31:0]		  AWGROUP_APB_AXI_A_ADDR;
   wire	[3:0]		  AWGROUP_APB_AXI_A_LEN;
   wire	[1:0]		  AWGROUP_APB_AXI_A_SIZE;
   wire			  AWGROUP_APB_AXI_A_VALID;
   wire	 		  AWGROUP_APB_AXI_A_READY;

   wire	[3:0]		  ARGROUP_APB_AXI_A_ID;
   wire	[31:0]		  ARGROUP_APB_AXI_A_ADDR;
   wire	[3:0]		  ARGROUP_APB_AXI_A_LEN;
   wire	[1:0]		  ARGROUP_APB_AXI_A_SIZE;
   wire			  ARGROUP_APB_AXI_A_VALID;
   wire	 		  ARGROUP_APB_AXI_A_READY;

   wire                   cmd_push;
   wire                   cmd_pop;
   wire                   cmd_empty;
   wire                   cmd_full;
   reg                    read;
   
   wire                   wreq, rreq;
   wire                   wack, rack;
   wire                   AERR;
   
   
   assign                 wreq = AWGROUP_APB_AXI_A_VALID;
   assign                 rreq = ARGROUP_APB_AXI_A_VALID;
   assign                 wack = AWGROUP_APB_AXI_A_VALID & AWGROUP_APB_AXI_A_READY;
   assign                 rack = ARGROUP_APB_AXI_A_VALID & AWGROUP_APB_AXI_A_READY;
         
   always @(posedge clk )
     if (~reset_n)
       read <= #1 1'b1;
     else if (wreq & (rack | (~rreq)))
       read <= #1 1'b0;
     else if (rreq & (wack | (~wreq)))
       read <= #1 1'b1;

	//command mux
	assign AGROUP_APB_AXI_A_ID    = read ? ARGROUP_APB_AXI_A_ID    : AWGROUP_APB_AXI_A_ID   ;
	assign AGROUP_APB_AXI_A_ADDR  = read ? ARGROUP_APB_AXI_A_ADDR  : AWGROUP_APB_AXI_A_ADDR ;
	assign AGROUP_APB_AXI_A_LEN   = read ? ARGROUP_APB_AXI_A_LEN   : AWGROUP_APB_AXI_A_LEN  ;
	assign AGROUP_APB_AXI_A_SIZE  = read ? ARGROUP_APB_AXI_A_SIZE  : AWGROUP_APB_AXI_A_SIZE ;
	assign AGROUP_APB_AXI_A_VALID = read ? ARGROUP_APB_AXI_A_VALID : AWGROUP_APB_AXI_A_VALID;
	assign AGROUP_APB_AXI_A_READY = read ? ARGROUP_APB_AXI_A_READY : AWGROUP_APB_AXI_A_READY;

	assign AERR   = (AGROUP_APB_AXI_A_SIZE != 'd2) | (AGROUP_APB_AXI_A_LEN != 'd0); //support only 32 bit single AXI commands
   
   assign ARGROUP_APB_AXI_A_READY = (~cmd_full) & read;
   assign AWGROUP_APB_AXI_A_READY = (~cmd_full) & (~read);
   
    assign 		      cmd_push  = AGROUP_APB_AXI_A_VALID & AGROUP_APB_AXI_A_READY;
    assign 		      cmd_pop   = cmd_read ? finish_rd : finish_wr;
   
   prgen_fifo #(4+32+2, 1) 
   cmd_fifo(
	    .clk(clk),
	    .reset_n(reset_n),
	    .push(cmd_push),
	    .pop(cmd_pop),
	    .din({
			AGROUP_APB_AXI_A_ID,
			AGROUP_APB_AXI_A_ADDR,
			AERR,
			read
			}
		 ),
	    .dout({
			cmd_id,
			cmd_addr,
			cmd_err,
			cmd_read
			}
		  ),
	    .empty(cmd_empty),
	    .full(cmd_full)
	    );

   
endmodule


