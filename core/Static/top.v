`timescale 1ns/1ps

module top(
	input    	  clock,
	input         rst_n,
	input  [31:0] light_intensity,
	output [ 3:0] count_out,
	output        xbs_select, 
    output [31:0] mem_addr,
    output [31:0] mem_data_in,
    output        mem_rnw,
    output [ 3:0] mem_be,
    input         mem_ack,
    input  [31:0] mem_data_out
    

);
  
//-------------------------------------------------------------------
// Reconfiguration controler
//-------------------------------------------------------------------
	
	`define RM_0_ADDR 32'h0
	`define RM_0_SIZE 16

	`define RM_1_ADDR 32'h20
	`define RM_1_SIZE 16

	`define SBT_HEADER_SIZE 16
	`define ONE_CYCLE_DELAY 10ns
	
	
	reg           count_rst ;
	wire          rc_done   ;
	reg           rc_trigger;
    reg           rc_start  ;
	reg           rc_bop    ;
	reg    [31:0] rc_baddr  ;
	reg    [31:0] rc_bsize  ;
	
	initial begin 
		rc_trigger= 1'b0;
		count_rst = 1'b1;#10;
		rc_start  = 1'b0;
		rc_bop    = 1'h0;
		rc_baddr  = 32'hffff_ffff;
		rc_bsize  = 32'hffff_ffff;
	end
 	
	reg [7:0] state_c, state_n, mod_c, mod_n;
	`define RST_S      	 8'h0
	`define START_RC     8'h1
	`define DURING_RC  	 8'h2
	`define END_RC       8'h3
	`define MOD_ADD  	 8'h4
	`define MOD_SUB      8'h5
	
	// State-indicator
	reg  [8*20:1] state_ascii;
	always @(*) begin
		if      (state_c==`RST_S	 ) 	state_ascii <= "RST_S     " ;
		else if (state_c==`START_RC  )  state_ascii <= "START_RC  " ;
		else if (state_c==`DURING_RC )  state_ascii <= "DURING_RC " ;
		else                        	state_ascii <= "END_RC    "	;
	end

	reg  [8*20:1] modc_ascii;
	always @(*) begin
		if      (mod_c  ==`MOD_ADD	 ) 	modc_ascii <= "MOD_ADD     " ;
		else                        	modc_ascii <= "MOD_SUB     "	;
	end

	reg  [8*20:1] modn_ascii;
	always @(*) begin
		if      (mod_n  ==`MOD_ADD	 ) 	modn_ascii <= "MOD_ADD     " ;
		else                        	modn_ascii <= "MOD_SUB     "	;
	end
	 // Main FSM
	always @(posedge clock or negedge rst_n) begin
		if (~rst_n) begin
			state_c <= `RST_S;
			mod_c	<= `MOD_ADD;
		end else
			state_c <= state_n;
			mod_c	<= mod_n;

	end
	
	always @(*) begin
		case (state_c)

			`RST_S	  :	begin 
				state_n = (~rst_n)? `RST_S      : `START_RC  ; count_rst = 1'b1;	end

			`START_RC :	begin 
				count_rst = 1'b0;
				if (mod_c == mod_n ) 
					state_n = `START_RC;  
				else begin				 
					state_n = `DURING_RC; 
					rc_start= 1'b1;
				end	
			end

			`DURING_RC:	begin 
				rc_start  = 1'b0;
				if (rc_done) begin
					state_n =  `START_RC  ;
					count_rst = 1'b1; 
				end else
					state_n =  `DURING_RC ;   
			end

			default	  : begin 
				state_n = `RST_S; 																	end
		endcase
	end	



	always @(light_intensity) begin	
		if (light_intensity < 32'd100) begin
			mod_n	   =`MOD_ADD;
			rc_bop     = 1'b1;
			rc_baddr   = `RM_0_ADDR;
			rc_bsize   = (`RM_0_SIZE+`SBT_HEADER_SIZE);
		end else begin
			mod_n	   =`MOD_SUB;
			rc_bop     = 1'b1;
			rc_baddr   = `RM_1_ADDR;
			rc_bsize   = (`RM_1_SIZE+`SBT_HEADER_SIZE);
		end
	end 

//-------------------------------------------------------------------
// Modules instantiation
//-------------------------------------------------------------------
  	icapi icapi_0 ( 
		.clk              (clock              ),
		.rstn             (rst_n              ),	
		.rc_start         (rc_start           ),// In : RC start
		.rc_bop           (rc_bop             ),// bop == 1'b0: rcfg, icap -> memory // bop == 1'b1: wcfg, memory -> icap
		.rc_baddr         (rc_baddr           ),// In 32bit: RC bitstream write_to HW region address
		.rc_bsize         (rc_bsize           ),// In 32bit: RC bitstream size
		.rc_done          (rc_done            ),// Out RC done
      /*
         For use with an ICAP arbiter. This signal is
         asserted by the IP on every clock cycle where
         it has data to transfer to the ICAP.
      */
		.ma_req           (                  ),// Out memory request
      /*
         For use with an ICAP arbiter. This signal is
         asserted by the arbiter to inform the
         HW_ICAP controller that it has permission to
         access the ICAP. After cap_gnt is asserted, it
         should remain asserted until cap_req is
         deasserted.
         If arbitration is not required, tie this signal to
         a constant 1
      */
		.xbm_gnt          (1'b1               ), //In :
		.ma_select        (xbs_select         ),// Out: Memeory select signal
		.ma_addr          (mem_addr           ),// Out: select Memory address
		.ma_data          (mem_data_in        ),// Out: write data to memory
		.ma_rnw           (mem_rnw            ),// Out: rnw=1, read mode; rnw=0, write mode
		.ma_be            (mem_be             ),// Out: Byte select 
		.xbm_ack          (mem_ack            ),// In : memory ACK signal
		.xbm_data         (mem_data_out       ) // In : memory data input to ICAP
	);


//-------------------------------------------------------------------
// ReSim_base static testing
//-------------------------------------------------------------------
   count inst_count (
      .rst       (count_rst),
      .clk       (clock),
      .count_out (count_out)
   );

endmodule


