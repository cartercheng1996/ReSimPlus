/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
****************************************************************************************************/
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

	// Configuration bitstream segment memory address and its length
	`define RR0_RM0_ADDR 32'h0
	`define RR0_RM0_SIZE 16

	`define RR0_RM1_ADDR 32'h20
	`define RR0_RM1_SIZE 16

	`define RR1_RM0_ADDR 32'h40
	`define RR1_RM0_SIZE 16

	`define RR1_RM1_ADDR 32'h60
	`define RR1_RM1_SIZE 16

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

	// FSM signal
	reg [7:0] state_c, state_n, mod_c, mod_n;
	`define RST_S      	 8'h0
	`define START_RC     8'h1
	`define DURING_RC  	 8'h2
	`define END_RC       8'h3
	`define MOD_UP  	 8'h4
	`define MOD_DOWN     8'h5
	`define MOD_ADD  	 8'h6
	`define MOD_SUB      8'h7
	`define RST_BEGIN	 8'hff


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
		if      (mod_c  ==`MOD_UP	 ) 	modc_ascii <= "MOD_UP"  ;
		else if (mod_c  ==`MOD_DOWN	 )  modc_ascii <= "MOD_DOWN";
		else if (mod_c  ==`MOD_ADD	 )  modc_ascii <= "MOD_ADD" ;
		else if (mod_c  ==`MOD_SUB	 )  modc_ascii <= "MOD_SUB" ;
		else modc_ascii <= "UNKNOW" ;
	end

	reg  [8*20:1] modn_ascii;
	always @(*) begin
		if      (mod_n  ==`MOD_UP	 ) 	modn_ascii <= "MOD_UP"  ;
		else if (mod_n  ==`MOD_DOWN	 )  modn_ascii <= "MOD_DOWN";
		else if (mod_n  ==`MOD_ADD	 )  modn_ascii <= "MOD_ADD" ;
		else if (mod_n  ==`MOD_SUB	 )  modn_ascii <= "MOD_SUB" ;
		else modn_ascii <= "UNKNOW" ;
	end

	// Main FSM (control single RM's configuration)
	always @(posedge clock) begin
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
				state_n = `RST_S;
			end
		endcase
	end


	//RR's FSM, control RMs swapping in each RR one by one

	// FSM signal
	reg [7:0] state_curr, state_next;
	`define IDIE 	  	  8'h0
	`define RR0_CONFG     8'h1
	`define RR1_CONFG  	  8'h2

	// State-indicator
	reg  [8*20:1] state_curr_ascii;
	always @(*) begin
		if      (state_curr==`IDIE	 	)  state_curr_ascii <= "IDIE" ;
		else if (state_curr==`RR0_CONFG )  state_curr_ascii <= "RR0_CONFG" ;
		else if (state_curr==`RR1_CONFG )  state_curr_ascii <= "RR1_CONFG " ;
	end

	reg  [8*20:1] state_next_ascii;
	always @(*) begin
		if      (state_next==`IDIE	 	) 	state_next_ascii <= "IDIE" ;
		else if (state_next==`RR0_CONFG )  	state_next_ascii <= "RR0_CONFG" ;
		else if (state_next==`RR1_CONFG ) 	state_next_ascii <= "RR1_CONFG " ;
	end








	always @(posedge clock or negedge rst_n) begin
		if (~rst_n) begin
			state_curr <= `IDIE;
		end else
			state_curr <= state_next;
	end

	reg [8:0] RR0_RM_chosen_curr;
	reg [8:0] RR0_RM_chosen_next;
	reg [8:0] RR1_RM_chosen_curr;
	reg [8:0] RR1_RM_chosen_next;

	always @(*) begin
		case (state_curr)

			`IDIE      :	begin
				if (RR0_RM_chosen_curr != RR0_RM_chosen_next) begin
					state_next = `RR0_CONFG;
				end else if (RR1_RM_chosen_curr != RR1_RM_chosen_next) begin
					state_next = `RR1_CONFG;
				end else begin
					state_next = `IDIE;
				end
			end

			`RR0_CONFG :	begin
				mod_n	   = RR0_RM_chosen_next;
				if (mod_n == `MOD_UP) begin
					rc_baddr   = `RR0_RM0_ADDR;
					rc_bsize   = (`RR0_RM0_SIZE+`SBT_HEADER_SIZE);
				end else if (mod_n == `MOD_DOWN) begin
					rc_baddr   = `RR0_RM1_ADDR;
					rc_bsize   = (`RR0_RM1_SIZE+`SBT_HEADER_SIZE);
				end
				if (rc_done && RR1_RM_chosen_curr != RR1_RM_chosen_next) begin
					state_next =  `RR1_CONFG;
					RR0_RM_chosen_curr = RR0_RM_chosen_next;
				end else if (rc_done && RR1_RM_chosen_curr == RR1_RM_chosen_next) begin
					state_next =  `IDIE;
					RR0_RM_chosen_curr = RR0_RM_chosen_next;
				end else begin
					state_next =  `RR0_CONFG ;
				end
			end

			`RR1_CONFG:	begin
				mod_n	   = RR1_RM_chosen_next;
				if (mod_n == `MOD_ADD) begin
					rc_baddr   = `RR1_RM0_ADDR;
					rc_bsize   = (`RR1_RM0_SIZE+`SBT_HEADER_SIZE);
				end else if (mod_n == `MOD_SUB) begin
					rc_baddr   = `RR1_RM1_ADDR;
					rc_bsize   = (`RR1_RM1_SIZE+`SBT_HEADER_SIZE);
				end
				if (rc_done && RR1_RM_chosen_curr != RR1_RM_chosen_next) begin
					state_next =  `IDIE;
					RR1_RM_chosen_curr = RR1_RM_chosen_next;
				end else if (rc_done && RR1_RM_chosen_curr == RR1_RM_chosen_next) begin
					state_next =  `IDIE;
					RR1_RM_chosen_curr = RR1_RM_chosen_next;
				end else begin
					state_next =  `RR1_CONFG ;
				end
			end

			default	  : begin
				state_next = `RR0_CONFG;
			end
		endcase
	end

	always @(posedge clock or negedge rst_n) begin
		if (~rst_n) begin
			RR0_RM_chosen_curr = `RST_BEGIN ;
			RR1_RM_chosen_curr = `RST_BEGIN ;
			mod_c = `RST_BEGIN;
			mod_n = `RST_BEGIN;
		end
	end

	always @(*) begin
		if (light_intensity < 32'd100) begin
			RR0_RM_chosen_next	   = `MOD_UP;
			RR1_RM_chosen_next	   = `MOD_ADD;
			rc_bop     = 1'b1;
		end else if (light_intensity < 32'd200) begin
			RR0_RM_chosen_next	   = `MOD_UP;
			RR1_RM_chosen_next	   = `MOD_SUB;
			rc_bop     = 1'b1;
		end else if (light_intensity < 32'd300) begin
			RR0_RM_chosen_next	   = `MOD_DOWN;
			RR1_RM_chosen_next	   = `MOD_ADD;
			rc_bop     = 1'b1;
		end else begin
			RR0_RM_chosen_next	   = `MOD_DOWN;
			RR1_RM_chosen_next	   = `MOD_SUB;
			rc_bop     = 1'b1;
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
	wire [3:0] RRs_count_out;

	always@(*) begin
		if (state_curr != `IDIE || ~rst_n) begin
			force RRs_count_out = 4'bx;
			force count_out =4'bx;
		end else begin
			release RRs_count_out;
			release count_out;
		end
	end

	count inst_count (
		.rst       (count_rst),
		.clk       (clock),
		.count_out (RRs_count_out)
	);

	arith inst_arith (
		.clk       (clock),
		.data      (RRs_count_out),
		.result    (count_out)
	);

endmodule
