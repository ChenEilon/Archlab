module	sat_count_tb;

reg clk, reset, branch, taken;
wire prediction2bit;
wire prediction3bit;
wire prediction4bit;

integer err_num;
reg tmp;

always #5 clk = ~clk;

sat_count sat_count_2bit(clk, reset, branch, taken, prediction2bit);
sat_count #(3) sat_count_5bit(clk, reset, branch, taken, prediction3bit);
sat_count #(4) sat_count_10bit(clk, reset, branch, taken, prediction4bit);

initial begin
	err_num = 0;

	$dumpfile("waves.vcd");
	$dumpvars;

	$display( "\nTest subtraction mode." );
	
    reset = 1;
    reset = 0;
    
    #5
    
    if(prediction2bit != 0 || prediction3bit !=0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in reset=1");
    end
    
    //1
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #1 branch");
    end
    
    
    //2
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #2 branch");
    end
    
    //3
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #3 branch");
    end
    
    //4
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #4 branch");
    end
    
    //5
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit !=1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #5 branch");
    end
    
    //6
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #6 branch");
    end
    
    //7
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #7 branch");
    end
    
    //8
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 0 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #8 branch");
    end
    
    //9
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #9 branch");
    end
    
    //10
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #10 branch");
    end
    
    //11
	branch = 1;
    tmp = prediction2bit;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #11 branch");
    end
    
    if (tmp == prediction2bit)
    begin
        err_num = err_num + 1;
        $display( "Error in #11 branch - update timing");
    end
    
    //12
	branch = 0;
    taken = 0;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #12 (no) branch");
    end
    
    //13
	branch = 0;
    taken = 0;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #13 (no) branch");
    end
    
    //14
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #14 (no) branch");
    end
    
    //15
	reset = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #15 reset");
    end
    
    //16
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #16 branch");
    end
    
    //17
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #17 branch");
    end
    
    //18
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #16 branch");
    end
    
	if( err_num==0 )
		$display( "\nPASSED ALL TESTS\n" );
	else
		$display( "\nFail, error number = %d\n", err_num );
	
	#10 $finish;
	end


endmodule