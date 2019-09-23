//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005-2012 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, Inc.
// All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 11.3
//  \   \        Application: Partial Reconfiguration
//  /   /        Filename: CountDown.v
// /___/   /\    Date Last Modified: 05 April 2012
// \   \  /  \
//  \___\/\___\
// Board:  KC705 Rev B with 
// Device: xc7k325t-1-ffg900
// Design Name: module_count
// Purpose: Partial Reconfiguration Tutorial
///////////////////////////////////////////////////////////////////////////////
// Reconfigurable Module: module_count
// Binary count down visable on 4 LEDs
`timescale 1ns/1ps
module count_down (
   rst,
   clk,
   count_out
);

   input rst;                // Active high reset
   input clk;                // 200MHz input clock
   output [3:0] count_out;   // Output to LEDs

   reg [7:0] count;
   reg [3:0]  count_out;
   

   //Counter to reduce speed of output
   always @(posedge clk)
      if (rst) begin
         count <= 0;
      end
      else begin
         count <= count + 1;
      end

    always @(posedge clk)
      if (rst)
         count_out <= 4'b1111;
      else begin
         if (count == 8'b11111111) begin
            count_out <= count_out - 1;
         end
      end
endmodule
