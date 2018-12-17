module sat_count(clk, reset, branch, taken, prediction);
   parameter N=2;
   input clk, reset, branch, taken;
   output prediction;
   
   reg[N-1:0] counter;
   reg prediction;
   

    always@ (posedge clk,reset,branch, taken)
    begin
        if (counter >= 2**(N-1))
            begin
            prediction <= 1;
            end
        else
            begin
            prediction <= 0;
            end
    end
   
   always @(reset,branch) //assuming branch and taken signals are ready together.
   begin
        if(reset == 1)
            begin
            counter = 0;
            end
        else 
            begin
            if(branch == 1)
                begin
                if(taken == 0)
                    begin
                    if(counter != 0)
                        begin
                        counter = counter - 1;
                        $display("debug1 - counter: %d\n", counter);
                        end
                    else
                        begin
                        $display("debug1 - counter: %d\n", counter);
                        end
                    end
                else // taken == 1
                    begin
                    if(counter != 2**N-1)
                        begin
                        counter = counter + 1;
                        $display("debug1 + counter: %d\n", counter);
                        end
                    else
                        begin
                        $display("debug1 - counter: %d\n", counter);
                        end
                    end
                end
            end
   end
   
   

endmodule
