            if (RM_ID == 8'd0) begin
            release   testbench.top_0.testbench.top_0.RM0.count_out;
            force     testbench.top_0.testbench.top_0.RM0.count=8'dx;
            force     testbench.top_0.testbench.top_0.RM0.up_0/out=8'dx;
            force     testbench.top_0.testbench.top_0.RM0.count_out=4'dx;
            force     testbench.top_0.testbench.top_0.RM0.count=8'dx;
            end else if (RM_ID == 8'd1) begin
            force     testbench.top_0.testbench.top_0.RM1.count_out=4'dx;
            release   testbench.top_0.testbench.top_0.RM1.count;
            force     testbench.top_0.testbench.top_0.RM1.up_0/out=8'dx;
            force     testbench.top_0.testbench.top_0.RM1.count_out=4'dx;
            force     testbench.top_0.testbench.top_0.RM1.count=8'dx;
tbench.top_0.RM1.count=8'dx;
