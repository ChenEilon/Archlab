module sat_count(clk, reset, branch, taken, prediction);
   parameter N=2;
   input clk, reset, branch, taken;
   output prediction;
   
   reg[N:0] counter;
   reg prediction;
   

    always@ (posedge clk,reset,branch, taken)
    begin
        if (counter >= 2**(N-1))
        begin
            prediction = 1;
            $display("debug2\n");
            end
        else
            prediction = 0;
    end
   
   always @(reset, taken)
   begin
        $display("debug3 \n");
        if(reset == 1)
            counter = 0;
        else if(branch == 1)
            begin
            $display("debug4 \n");
            if(taken == 0)
                begin
                $display("debug5 \n");
                if(counter != 0)
                    counter = counter - 1;
                end
            else // taken == 1
                begin
                $display("debug6 \n");
                if(counter != 2**N-1)
                    begin
                    counter = counter + 1;
                    $display("debug1 - counter: %d\n", counter);
                    end
                end
            end
   end
   
   

endmodule
