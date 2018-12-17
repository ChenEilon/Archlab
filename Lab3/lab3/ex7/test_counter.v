module test_counter(r,up,down,p)
input r;
input up;
input down;
output p;

parameter N=2;

reg[N-1:0] counter;

always @(up,down)
begin
    if(r = 1)
        counter = 0;
    else if(up = 1)
        counter = counter + 1;
    else
        counter = counter - 1;
    $display("%d",counter);
    
    if(counter >3)
        p = 1;
    else
        p=0;
end



endmodule 