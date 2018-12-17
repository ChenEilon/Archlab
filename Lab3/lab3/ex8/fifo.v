module fifo(clk, reset, in, push, pop, out, full);
  parameter N=4; // determines the maximum number of words in queue.
  parameter M=2; // determines the bit-width of each word, stored in the queue.

  input clk, reset, push, pop;
  input [M-1:0] in;
  output [M-1:0] out;
  output full;
  
  reg [M-1:0] out;
  reg [M-1:0] W [N-1:0];
  reg n;
  integer i;
  
  assign full = n == N;

  always @(posedge clk)
  begin
    if (reset)
      n <= 0;
    
    else begin
      if (n == 0)
        if (push) begin
          W[0] <= in;
          n <= 1;
        end
      
      else if (n > 0 && n < N)
        if (push) begin
          W[0] <= in;
          for (i = 0; i < n; i = i+1)
            W[i+1] <= W[i];
          if (!pop)
            n <= n+1;
        end else if (pop)
          n <= n-1;
      
      else if (pop)
        if (push) begin
          W[0] <= in;
          for (i = 0; i < N-1; i = i+1)
            W[i+1] <= W[i];
        end else
          n <= n-1;
    end
    
    if (n > 0)
      out <= W[n-1];
    else
      out <= 0;
  end
endmodule
