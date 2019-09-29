/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
This is ReSimPlus auto generated file, use for simulation only!
The purpose of this file is to separate the simulation-only code-section. (Which can't be Sync. or elaborated)
****************************************************************************************************/
//---------------------------------------------
// Update MUX_TOP.do generated file MUX-signal
//---------------------------------------------

    always@(*)
    begin
        if (RR_ID == 8'h00 ) begin
            if (RM_ID == 8'h00) begin
                testbench.top_0.inst_count.RM0_active <=1;
                testbench.top_0.inst_count.RM1_active <=0;
            end else if (RM_ID == 8'h01) begin
                testbench.top_0.inst_count.RM0_active <=0;
                testbench.top_0.inst_count.RM1_active <=1;
            end

        end else if (RR_ID == 8'h01 ) begin
            if (RM_ID == 8'h00) begin
                testbench.top_0.inst_arith.RM0_active <=1;
                testbench.top_0.inst_arith.RM1_active <=0;
            end else if (RM_ID == 8'h01) begin
                testbench.top_0.inst_arith.RM0_active <=0;
                testbench.top_0.inst_arith.RM1_active <=1;
            end
        end else if (RR_ID == 8'h02 ) begin
            if (RM_ID == 8'h00) begin
                testbench.top_0.inst_op.RM0_active <=1;
                testbench.top_0.inst_op.RM1_active <=0;
                testbench.top_0.inst_op.RM2_active <=0;
            end else if (RM_ID == 8'h01) begin
                testbench.top_0.inst_op.RM0_active <=0;
                testbench.top_0.inst_op.RM1_active <=1;
                testbench.top_0.inst_op.RM2_active <=0;
            end else if (RM_ID == 8'h02) begin
                testbench.top_0.inst_op.RM0_active <=0;
                testbench.top_0.inst_op.RM1_active <=0;
                testbench.top_0.inst_op.RM2_active <=1;
            end
        end
    end

//---------------------------------------------
//           State-restoration part
//---------------------------------------------
    always@(*)
    begin
        if (RR_ID == 8'h00 ) begin
            if (RM_ID == 8'h00) begin
                release   testbench.top_0.inst_count.RM0.count_out;
                release   testbench.top_0.inst_count.RM0.count;
                release   testbench.top_0.inst_count.RM0.up_0.out;
                force     testbench.top_0.inst_count.RM1.count_out=4'dx;
                force     testbench.top_0.inst_count.RM1.count=8'dx;
            end else if (RM_ID == 8'h01) begin
                force     testbench.top_0.inst_count.RM0.count_out=4'dx;
                force     testbench.top_0.inst_count.RM0.count=8'dx;
                force     testbench.top_0.inst_count.RM0.up_0.out=8'dx;
                release   testbench.top_0.inst_count.RM1.count_out;
                release   testbench.top_0.inst_count.RM1.count;
            end
        end else if (RR_ID == 8'h01) begin
            if (RM_ID == 8'h00) begin
                release   testbench.top_0.inst_arith.RM0.result;
                force     testbench.top_0.inst_arith.RM1.result=4'dx;
            end else if (RM_ID == 8'h01) begin
                force     testbench.top_0.inst_arith.RM0.result=4'dx;
                release   testbench.top_0.inst_arith.RM1.result;
            end
        end else if (RR_ID == 8'h02) begin
            if (RM_ID == 8'h00) begin
                force     testbench.top_0.inst_op.RM1.result=5'dx;
                force     testbench.top_0.inst_op.RM2.compare=4'dx;
                release   testbench.top_0.inst_op.RM0.result;
            end else if (RM_ID == 8'h01) begin
                force     testbench.top_0.inst_op.RM0.result=5'dx;
                force     testbench.top_0.inst_op.RM2.result=5'dx;
                force     testbench.top_0.inst_op.RM2.compare=4'dx;
            end else if (RM_ID == 8'h02) begin
                force     testbench.top_0.inst_op.RM0.result=5'dx;
                force     testbench.top_0.inst_op.RM1.result=5'dx;
                release   testbench.top_0.inst_op.RM2.compare;
            end
        end
    end
