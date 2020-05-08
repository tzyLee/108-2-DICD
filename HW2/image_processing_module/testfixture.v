`timescale 1ns/10ps
`define CYCLE      100
`define ENDCYCLE    100000
`define SDFFILE     "./syn/imgproc_syn.sdf"	  // Modify your sdf file name
`define PAT         "./data/pattern1_hex.dat"    
`define EXP         "./data/golden1_hex.dat"     


module testfixture();

    // parameter declare
    parameter N_EXP   = 16384; // 128 x 128 pixel
    parameter N_PAT   = N_EXP;
    integer     i;

    // register declare
    reg [23:0]  color_mem  [0:N_PAT-1];
    reg [7:0]   exp_mem    [0:N_EXP-1];
    reg [7:0]   my_mem     [0:N_EXP-1];
    reg [7:0]   golden;
    reg [14:0]  err_count;

    reg         clk;
    reg         rst;
    reg [23:0]  orig_data;
    reg         orig_ready;
    wire [13:0] orig_addr;
    wire        request;
    wire [13:0] imgproc_addr;
    wire        imgproc_ready;
    wire [7:0]  imgproc_data;
    wire        finish;

    // module declare
    imgproc myName(clk,rst,orig_data,orig_ready,request,orig_addr,imgproc_ready,imgproc_addr,imgproc_data,finish);
    // for gate level netlist
    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, myName);
    `endif

    // dump wave file
    initial begin
    `ifdef FSDB 
        $fsdbDumpfile("imgproc.fsdb");
        $fsdbDumpvars(0,testfixture); 
    `endif
    end

    // clock generate
    always #(`CYCLE/2) clk  = ~clk;

    // eat pattern and golden
    initial	$readmemh (`PAT, color_mem);
    initial	$readmemh (`EXP, exp_mem);


    // -------------------  start here !!! ----------------------
    initial begin
        clk = 0;
        rst = 0;
        @(negedge clk)  rst = 1;
        #(`CYCLE*2)     rst = 0;
    
        while(finish == 0) begin
            @(negedge clk);
            if(request==1) begin
                orig_data= color_mem[orig_addr];
                if(orig_data) orig_ready= 1;
                else orig_ready=0;
            end
            else begin
                orig_data= 24'bz;
                orig_ready= 0;
            end
        end
        orig_data= 24'bz;
        orig_ready= 0;

    end

    // ------------------ verify !!! --------------------
    initial begin	
        $display("-----------------------------------------------------\n");
        $display("START!!! Simulation Start .....\n");
        $display("-----------------------------------------------------\n");
        err_count = 0;
        #(`CYCLE*3);
        i = 0;
        while(finish == 0 ) begin
            @(negedge clk);
            if(imgproc_ready) begin
                golden = exp_mem[i];
                i = i+1;
                my_mem[imgproc_addr] = imgproc_data;
            end
        end					

        #(`CYCLE);
        for(i=0;i<N_PAT;i = i+1) begin
            if(my_mem[i]==exp_mem[i]) begin
                err_count = err_count;
            end
            else begin
                $display("%dth Pixel is wrong :%h != %h !\n",i,my_mem[i],exp_mem[i] );
                err_count = err_count + 1;   
            end
        end
        if ( err_count == 0) begin
            $display("===============================================\n");
            $display(" Congratulations!!! Every outputs are correct! \n");
            $display("===============================================\n");
            end
        else
            $display("The wrong pixels reached a total of %d or more ! \n", err_count);
        $finish;
    end

    // check time-out
    initial begin
        #(`CYCLE*`ENDCYCLE);
        $display("Time-out Error! Maybe there is something wrong with the 'finish' signal \n");
        $finish;
    end

endmodule

