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

reg r,up,down,p1,p2; //TODO DEL
test_counter tc1(r,up,down,p1);
test_counter #(3) tc2(r,up,down,p2):

initial begin
	err_num = 0;

	$dumpfile("waves.vcd");
	$dumpvars;

    ///////////////////////TODO DEL
    r = 1;
    up = 1;
    up = 1;
    up = 1;
    $display("p1: %d, p2: %d",p1,p2);
    
    
    ///////////////////////
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
        $display("Error in #1 branch\n");
        $display("prediction2bit: %d (0),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    
    //2
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #2 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //3
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #3 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //4
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #4 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //5
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit !=1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #5 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //6
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #6 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //7
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #7 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //8
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 0 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #8 branch");
        $display("prediction2bit: %d (0),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //9
	branch = 1;
    taken = 0;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #9 branch");
        $display("prediction2bit: %d (0),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //10
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #10 branch");
        $display("prediction2bit: %d (0),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
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
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
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
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //13
	branch = 0;
    taken = 0;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #13 (no) branch");
        $display("prediction2bit: %d (01),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //14
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 1 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #14 (no) branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(1), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //15
	reset = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #15 reset");
        $display("prediction2bit: %d (0),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //16
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 0 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #16 branch");
        $display("prediction2bit: %d (0),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //17
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #17 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
    //18
	branch = 1;
    taken = 1;
    #5
    if(prediction2bit != 1 || prediction3bit != 0 || prediction4bit != 0 )
    begin
        err_num = err_num + 1;
        $display( "Error in #18 branch");
        $display("prediction2bit: %d (1),prediction3bit: %d(0), prediction4bit %d(0)\n",prediction2bit,prediction3bit,prediction4bit);
    end
    
	if( err_num==0 )
		$display( "\nPASSED ALL TESTS\n" );
	else
		$display( "\nFail, error number = %d\n", err_num );
	
	#10 $finish;
	end


endmodule